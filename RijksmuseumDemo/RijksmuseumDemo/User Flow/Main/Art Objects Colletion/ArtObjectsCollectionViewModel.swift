//
//  ArtObjectsCollectionViewModel.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import Foundation
import Combine
import Kingfisher


struct CollectionPageSection: Hashable {
    let title: String
    let artObjects: [ArtObject]
}


protocol ArtObjectsViewModelDependencies {
    var artObjectsService: ArtObjectsServiceProtocol { get }
}


struct DefaultArtObjectsViewModelDependencies: ArtObjectsViewModelDependencies {
    let artObjectsService: ArtObjectsServiceProtocol

    init() {
        artObjectsService = ArtObjectsService(
            apiClient: DefaultAPIClient(),
            cultureProvider: DefaultCultureProvider(localeProvider: DefaultLocaleProvider())
        )
    }
}


@MainActor
final class ArtObjectsCollectionViewModel {

    // MARK: - Observable properties

    @Published private(set) var sections: [CollectionPageSection] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    /// Use this subject to bind signals that better be debounced
    let fetchSubject = PassthroughSubject<Void, Never>()

    // MARK: - Private properties

    private var currentPage = APIConstants.collectionFirstPage - 1
    private let artObjectsService: ArtObjectsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(dependencies: ArtObjectsViewModelDependencies) {
        artObjectsService = dependencies.artObjectsService

        fetchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard self?.errorMessage == nil else { return }
                self?.fetchArtObjects()
            }
            .store(in: &cancellables)
    }

    func fetchArtObjects() {
        guard isLoading == false else { return }

        self.errorMessage = nil
        self.isLoading = true

        Task {
            let result = await artObjectsService.fetchArtObjects(page: currentPage + 1)
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.currentPage += 1
                    self.sections += [CollectionPageSection(
                        title: "Page \(self.currentPage)",
                        artObjects: response.artObjects
                    )]
                case .failure(let error):
                    let message = "Something wrong happened. Try again later.\n\(error.localizedDescription)"
                    self.errorMessage = message
                }
        }
    }

    func prefetchImages(forObjectsAt indexPaths: [IndexPath]) {
        indexPaths
            .compactMap {
                sections[$0.section]
                    .artObjects
                    .compactMap { URL(string: $0.webImage.url) }
            }
            .forEach { ImagePrefetcher(urls: $0).start() }
    }

    func prefetchObjects() {
        if currentPage < APIConstants.collectionFirstPage {
            fetchArtObjects()
        }
    }

    func prefetchObjects(for indexPath: IndexPath) {
        guard indexPath.section == sections.count - 1,
        let artObjectsInSection = sections.last?.artObjects.count
        else { return }
        
        if indexPath.row + 1 >= artObjectsInSection - 4 {
            fetchSubject.send()
        }
    }

    func prefetchObjects(for indexPaths: [IndexPath]) {
        if let maxIndexPath = indexPaths.max() { prefetchObjects(for: maxIndexPath) }
    }

}
