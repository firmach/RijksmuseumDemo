//
//  ArtObjectsServiceTests.swift
//  RijksmuseumDemoTests
//
//  Created by Roman Churkin on 28/05/2023.
//

import XCTest
@testable import RijksmuseumDemo


final class ArtObjectsServiceTests: XCTestCase {

    var mockCultureProvider: MockCultureProvider!

    override func setUp() {
        super.setUp()
        mockCultureProvider = MockCultureProvider()
    }

    func testFetchArtObjects() async throws {
        let expectedWebImage = WebImage(guid: "unique-guid", url: "https://example.com/image.jpg")
        let expectedArtObject = ArtObject(
            id: "unique-id",
            objectNumber: "object-1234",
            title: "Art Title",
            principalOrFirstMaker: "John Doe",
            webImage: expectedWebImage
        )
        let expectedArtObjects = [expectedArtObject]
        let expectedResponse = CollectionResponse(count: 999, artObjects: expectedArtObjects)

        let mockApiClient = MockAPIClient<CollectionResponse>()
        mockApiClient.resultToReturn = .success(expectedResponse)

        let artObjectsService = ArtObjectsService(apiClient: mockApiClient, cultureProvider: mockCultureProvider)

        let result = await artObjectsService.fetchArtObjects(page: 1)

        switch result {
        case .success(let response):
            XCTAssertEqual(response, expectedResponse)
        case .failure(let error):
            XCTFail("Expected success, but got \(error) instead.")
        }
    }

    func testFetchArtObjectDetails() async throws {
        let expectedResponse = ArtObjectDetailResponse(
            artObject: ArtObjectDetails(
                id: "unique-id",
                objectNumber: "object-1234",
                description: "An amazing artwork",
                webImage: WebImage(guid: "unique-id", url: "https://example.com/image1.jpg"),
                longTitle: "Amazing Artwork by XYZ",
                subTitle: "Amazing Artwork size",
                colors: [
                    ArtObjectDetails.Color(percentage: 20, hex: "#FFFFFF"),
                    ArtObjectDetails.Color(percentage: 80, hex: "#000000")
                ],
                principalMaker: "XYZ"
            )
        )

        let mockApiClient = MockAPIClient<ArtObjectDetailResponse>()
        mockApiClient.resultToReturn = .success(expectedResponse)

        let artObjectsService = ArtObjectsService(apiClient: mockApiClient, cultureProvider: mockCultureProvider)

        let result = await artObjectsService.fetchArtObjectDetails(objectNumber: "object-1234")

        switch result {
        case .success(let response):
            XCTAssertEqual(response, expectedResponse)
        case .failure(let error):
            XCTFail("Expected success, but got \(error) instead.")
        }
    }

    func testFetchArtObjectsFailure() async throws {
        let expectedError = NetworkError.invalidURL

        let mockApiClient = MockAPIClient<CollectionResponse>()
        mockApiClient.resultToReturn = .failure(expectedError)

        let artObjectsService = ArtObjectsService(apiClient: mockApiClient, cultureProvider: mockCultureProvider)

        let result = await artObjectsService.fetchArtObjects(page: 1)

        switch result {
        case .success(let response):
            XCTFail("Expected failure, but got \(response) instead.")
        case .failure(let error):
            /*
             This specific check can lead to inconsistent test results.
             It would be more effective to implement a reliable and fair error type check.
             */
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }

    func testFetchArtObjectDetailsFailure() async throws {
        let expectedError = NetworkError.noResponse

        let mockApiClient = MockAPIClient<ArtObjectDetailResponse>()
        mockApiClient.resultToReturn = .failure(expectedError)

        let artObjectsService = ArtObjectsService(apiClient: mockApiClient, cultureProvider: mockCultureProvider)

        let result = await artObjectsService.fetchArtObjectDetails(objectNumber: "object-1234")

        switch result {
        case .success(let response):
            XCTFail("Expected failure, but got \(response) instead.")
        case .failure(let error):
            /*
             This specific check can lead to inconsistent test results.
             It would be more effective to implement a reliable and fair error type check.
             */
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }

}


// MARK: - Mocks

final class MockAPIClient<T: Decodable>: APIClient {
    var resultToReturn: Result<T, NetworkError>!

    func sendRequest<T>(_ endpoint: Endpoint, ofType: T.Type) async -> Result<T, NetworkError> {
        return resultToReturn as! Result<T, NetworkError>
    }
}

final class MockCultureProvider: CultureProvider {
    var culture = "en"
}
