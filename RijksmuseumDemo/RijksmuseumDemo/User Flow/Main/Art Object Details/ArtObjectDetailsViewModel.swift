//
//  ArtObjectDetailsViewModel.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit
import Combine
import Kingfisher


protocol ArtObjectDetailsViewModelDependencies {
    var artObjectsService: ArtObjectsServiceProtocol { get }
}


struct DefaultArtObjectDetailsViewModelDependencies: ArtObjectDetailsViewModelDependencies {
    let artObjectsService: ArtObjectsServiceProtocol

    init() {
        artObjectsService = ArtObjectsService(
            apiClient: DefaultAPIClient(),
            cultureProvider: DefaultCultureProvider(localeProvider: DefaultLocaleProvider())
        )
    }

}


@MainActor final class ArtObjectDetailsViewModel {

    // MARK: - Public properties

    @Published private(set) var artObjectDetails: ArtObjectDetails? = nil
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil


    // MARK: - Private properties

    private let objectNumber: String
    private let artObjectsService: ArtObjectsServiceProtocol
    private var cancellables = Set<AnyCancellable>()


    // MARK: - Init

    init(objectNumber: String, dependencies: ArtObjectsViewModelDependencies) {
        self.artObjectsService = dependencies.artObjectsService
        self.objectNumber = objectNumber
        setupBindings()
    }


    // MARK: - Private helpers

    private func setupBindings() {
        $artObjectDetails
            .filter { $0 != nil }
            .map { $0?.webImage.url ?? "" }
            .sink { [weak self] in self?.fetchImage(for: $0) }
            .store(in: &cancellables)

        $artObjectDetails
            .combineLatest($image, $errorMessage)
            .map { ($0 == nil || $1 == nil) && $2 == nil }
            .sink { [weak self] in self?.isLoading = $0 }
            .store(in: &cancellables)
    }

    private func fetchImage(for rawURL: String) {
        guard let url = URL(string: rawURL) else { return }

        let processor = DownsamplingImageProcessor(size: .init(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        ))

        /*
         In order to cover the ArtObjectDetailsViewModel with unit tests,
         it's necessary to abstract the KingfisherManager.
         This abstraction will allow us to replace it with a stub during testing.
         */
        KingfisherManager.shared.retrieveImage(
            with: ImageResource(downloadURL: url),
            options: [.processor(processor)]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult): self.image = imageResult.image
            case .failure(let error):
                let message = "Something wrong happened. Try again later.\n\(error.localizedDescription)"
                self.errorMessage = message
            }
        }
    }


    // MARK - Public methods

    func fetchDetails() {
        errorMessage = nil
        artObjectDetails = nil
        image = nil

        Task {
            let result = await artObjectsService.fetchArtObjectDetails(objectNumber: objectNumber)
                switch result {
                case .success(let response):
                    self.artObjectDetails = response.artObject
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
        }
    }

}
