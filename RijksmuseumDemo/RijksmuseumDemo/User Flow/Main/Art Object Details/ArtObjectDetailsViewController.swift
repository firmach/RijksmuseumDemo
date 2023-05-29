//
//  ArtObjectDetailsViewController.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit
import Combine


@MainActor
final class ArtObjectDetailsViewController: UIViewController {

    // MARK: - Private properties

    private var viewModel: ArtObjectDetailsViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.alpha = 0.0
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let principalMakerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let colorsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private let errorView: ErrorModalView = {
        let errorView = ErrorModalView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

    private var imageHeight: NSLayoutConstraint?

    private var cancellables = Set<AnyCancellable>()


    // MARK: - Init

    init(viewModel: ArtObjectDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchDetails()
    }


    // MARK: - Private helpers

    private func setupBindings() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self?.scrollView.alpha = isLoading ? 0.0 : 1.0
                })
            }
            .store(in: &cancellables)

        viewModel.$image
            .sink { [weak self] in self?.set(image: $0) }
            .store(in: &cancellables)

        viewModel.$artObjectDetails
            .sink { [weak self] details in
                self?.scrollView.isHidden = details == nil
                guard let self = self,
                      let details else { return }
                self.populate(with: details)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] error in
                self?.errorView.setErrorMessage(error)
                self?.errorView.isHidden = error == nil
            }
            .store(in: &cancellables)

        errorView.onRetry = { [weak self] in
            self?.viewModel.fetchDetails()
        }
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [
            titleLabel,
            principalMakerLabel,
            imageView,
            sizeLabel,
            colorsStackView,
            descriptionLabel,
        ].forEach(contentView.addSubview)

        view.addSubview(loadingIndicator)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            principalMakerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            principalMakerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            principalMakerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            imageView.topAnchor.constraint(equalTo: principalMakerLabel.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            sizeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            colorsStackView.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 16),
            colorsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorsStackView.heightAnchor.constraint(equalToConstant: 44),

            descriptionLabel.topAnchor.constraint(equalTo: colorsStackView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func set(image: UIImage?) {
        imageView.image = image

        guard let image = image else { return }

        if let imageHeight = imageHeight {
            imageView.removeConstraint(imageHeight)
        }

        imageHeight = imageView.widthAnchor.constraint(
            equalTo: imageView.heightAnchor,
            multiplier: image.size.width/image.size.height
        )
        imageHeight?.isActive = true

        view.layoutIfNeeded()
    }

    private func populate(with artObjectDetails: ArtObjectDetails) {
        titleLabel.text = artObjectDetails.longTitle
        sizeLabel.text = artObjectDetails.subTitle
        descriptionLabel.text = artObjectDetails.description
        principalMakerLabel.text = artObjectDetails.principalMaker

        colorsStackView.arrangedSubviews
            .forEach(colorsStackView.removeArrangedSubview)

        if artObjectDetails.colors.isEmpty {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textAlignment = .center
            label.text = "No colors available 😔"
            colorsStackView.addArrangedSubview(label)
        } else {
            artObjectDetails.colors
                .map {
                    let colorView = UIView()
                    colorView.backgroundColor = UIColor(hex: $0.hex)
                    colorView.layer.cornerRadius = 4
                    return colorView
                }
                .forEach(colorsStackView.addArrangedSubview)
        }
    }

}
