//
//  ArtObjectsCollectionViewController.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit
import Combine


enum CollectionPreferredLayout {
    case row, grid
}


@MainActor
final class ArtObjectsCollectionViewController: UICollectionViewController, TransientOverlayDisplayable {

    // MARK: - Internal types declaration

    typealias DataSource = UICollectionViewDiffableDataSource<CollectionPageSection, ArtObject>
    typealias Snapshot = NSDiffableDataSourceSnapshot<CollectionPageSection, ArtObject>


    // MARK: - Private properties

    private weak var coordinator: MainCoordinator?
    private let viewModel: ArtObjectsCollectionViewModel
    private lazy var dataSource = makeDataSource()
    private var cancellables = Set<AnyCancellable>()

    private var preferredLayout = CollectionPreferredLayout.row

    private var flipLayoutButton: UIBarButtonItem!
    private var loadingView: UIView? = nil
    private var errorView: UIView? = nil


    // MARK: - Initialization

    init(coordinator: MainCoordinator, viewModel: ArtObjectsCollectionViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupCollectionView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.prefetchObjects()
    }


    // MARK: - UICollectionView Lifecycle

    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        viewModel.prefetchObjects(for: indexPath)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let artObject = section.artObjects[indexPath.row]
        coordinator?.detailArtObject(artObject: artObject)
    }

}


extension ArtObjectsCollectionViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        viewModel.prefetchImages(forObjectsAt: indexPaths)
        viewModel.prefetchObjects(for: indexPaths)
    }

}


private extension ArtObjectsCollectionViewController {

    // MARK: - Setup helpers

    func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.prefetchDataSource = self
        collectionView.isPrefetchingEnabled = true

        collectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CollectionHeaderView"
        )

        collectionView.register(
            ArtObjectCollectionViewCell.self,
            forCellWithReuseIdentifier: "ArtObjectCollectionViewCell"
        )
        changeLayout(to: preferredLayout)
    }

    func setupNavigationItem() {
        title = "Rijksmuseum"
        navigationItem.largeTitleDisplayMode = .always

        flipLayoutButton = UIBarButtonItem(
            image: UIImage(systemName: "square.grid.2x2"),
            style: .plain,
            target: self,
            action: #selector(togglePreferredLayout)
        )
        navigationItem.rightBarButtonItem = flipLayoutButton
    }

    func setupBindings() {
        viewModel.$sections
            .sink { [weak self] in self?.updateDatasource(with: $0) }
            .store(in: &cancellables)

        viewModel.$isLoading
            .sink { [weak self] in
                if $0 { self?.showLoadingIndicator() }
                else { self?.hideLoadingIndicator() }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] in
                if let errorMessage = $0 {
                    self?.showErrorView(with: errorMessage)
                } else {
                    self?.hideErrorView()
                }
            }
            .store(in: &cancellables)
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, artObject) -> UICollectionViewCell? in
                guard let self = self else { return nil}

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArtObjectCollectionViewCell",
                    for: indexPath
                ) as? ArtObjectCollectionViewCell

                cell?.preferredLayout = self.preferredLayout
                cell?.configure(with: artObject)

                return cell
            })

        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            if kind == UICollectionView.elementKindSectionHeader {
                let datasource = collectionView.dataSource as! DataSource
                let snapshot = datasource.snapshot()
                let section = snapshot.sectionIdentifiers[indexPath.section]

                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "CollectionHeaderView",
                    for: indexPath
                ) as! CollectionHeaderView

                headerView.configure(with: section.title)

                return headerView
            }

            fatalError("Unexpected request for supplementaryView")
        }

        return dataSource
    }

    func changeLayout(to preferredLayout: CollectionPreferredLayout) {
        let item: NSCollectionLayoutItem
        let groupSize: NSCollectionLayoutSize

        switch preferredLayout {
        case .row:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 32, trailing: 8)

            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5))

        case .grid:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0))

            item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.5))

        }

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }


    // MARK: - Lifecycle helpers

    private func updateDatasource(with sections: [CollectionPageSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { snapshot.appendItems($0.artObjects, toSection: $0) }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func showLoadingIndicator() {
        guard loadingView == nil else { return }
        self.loadingView = LoadingCircleView()
        showOverlay(loadingView!, autoHide: false)
    }

    func hideLoadingIndicator() {
        if let loadingView = loadingView {
            hideOverlay(loadingView)
            self.loadingView = nil
        }
    }

    func showErrorView(with message: String) {
        guard errorView == nil else { return }

        let errorView = ErrorToastView()
        errorView.setErrorMessage(message)
        errorView.onRetry = { [weak self] in self?.viewModel.fetchArtObjects() }
        showOverlay(errorView, autoHide: false)
        self.errorView = errorView

        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: errorView.bounds.height + TransientOverlayDisplayableConstants.bottomPadding,
            right: 0
        )
    }

    func hideErrorView() {
        if let errorView = errorView {
            hideOverlay(errorView)
            self.errorView = nil

            let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height
            if bottomEdge >= collectionView.contentSize.height {
                let offsetY = collectionView.contentOffset.y - errorView.frame.minY + self.view.safeAreaLayoutGuide.layoutFrame.maxY
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.setContentOffset(
                        CGPoint(x: 0, y: offsetY),
                        animated: false
                    )
                    self.collectionView.contentInset = .zero
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.contentInset = .zero
                }
            }
        }
    }


    // MARK: - UIActions

    @objc func togglePreferredLayout() {
        switch preferredLayout {
        case .row:
            flipLayoutButton.image = UIImage(systemName: "rectangle.grid.1x2")
            preferredLayout = .grid
        case .grid:
            flipLayoutButton.image = UIImage(systemName: "square.grid.2x2")
            preferredLayout = .row
        }
        changeLayout(to: preferredLayout)
        collectionView.reloadData()
    }

}
