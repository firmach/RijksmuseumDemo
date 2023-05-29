//
//  ArtObjectsService.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


protocol ArtObjectsServiceProtocol {

    func fetchArtObjects(page: Int) async -> Result<CollectionResponse, NetworkError>

    func fetchArtObjectDetails(objectNumber: String) async -> Result<ArtObjectDetailResponse, NetworkError>

}


struct ArtObjectsService: ArtObjectsServiceProtocol {
    
    let apiClient: APIClient
    let cultureProvider: CultureProvider
    let apiKey = APIConstants.apiKey

    init(
        apiClient: APIClient,
        cultureProvider: CultureProvider
    ) {
        self.apiClient = apiClient
        self.cultureProvider = cultureProvider
    }

    func fetchArtObjects(page: Int) async -> Result<CollectionResponse, NetworkError> {
        let endpoint = CollectionEndpoint(
            apiKey: apiKey,
            culture: cultureProvider.culture,
            page: page
        )

        return await apiClient.sendRequest(endpoint, ofType: CollectionResponse.self)
    }

    func fetchArtObjectDetails(objectNumber: String) async -> Result<ArtObjectDetailResponse, NetworkError> {
        let endpoint = ArtObjectDetailsEndpoint(
            apiKey: apiKey,
            culture: cultureProvider.culture,
            objectNumber: objectNumber
        )

        return await apiClient.sendRequest(endpoint, ofType: ArtObjectDetailResponse.self)
    }

}
