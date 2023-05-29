//
//  ArtObjectsCollectionViewModelTests.swift
//  RijksmuseumDemoTests
//
//  Created by Roman Churkin on 29/05/2023.
//

import XCTest
import Combine
@testable import RijksmuseumDemo


final class ArtObjectsViewModelTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    @MainActor
    func testCorrectLoadingStages() throws {
        let mockService = MockArtObjectsService()
        mockService.fetchArtObjectsResult = .success(
            CollectionResponse(
                count: 999,
                artObjects: [ArtObject(
                    id: "1",
                    objectNumber: "1",
                    title: "test",
                    principalOrFirstMaker: "test",
                    webImage: WebImage(guid: "1", url: "test")
                )]
            )
        )

        let dependencies = MockArtObjectsCollectionDependencies(artObjectsService: mockService)
        let viewModel = ArtObjectsCollectionViewModel(dependencies: dependencies)

        XCTAssertFalse(viewModel.isLoading)

        let expectationTrueSet = XCTestExpectation(description: "isLoading True test")
        let expectationFalseSet = XCTestExpectation(description: "isLoading False test")

        var count = 0
        viewModel.$isLoading
            .sink { isLoading in
                switch count {
                case 1:
                    XCTAssertTrue(isLoading)
                    expectationTrueSet.fulfill()
                case 2:
                    XCTAssertFalse(isLoading)
                    expectationFalseSet.fulfill()
                    XCTAssertEqual(mockService.requestedPage, APIConstants.collectionFirstPage)
                default: break
                }
                count += 1
            }
            .store(in: &cancellables)

        viewModel.fetchArtObjects()

        wait(for: [expectationTrueSet, expectationFalseSet], timeout: 0.25)
    }

    @MainActor
    func testCorrectErrorMessageStages() throws {
        let mockService = MockArtObjectsService()
        mockService.fetchArtObjectsResult = .failure(NetworkError.noResponse)

        let dependencies = MockArtObjectsCollectionDependencies(artObjectsService: mockService)
        let viewModel = ArtObjectsCollectionViewModel(dependencies: dependencies)

        XCTAssertNil(viewModel.errorMessage)

        let expectationErrorMessageSetSome = XCTestExpectation(description: "error message set")
        let expectationErrorMessageSetNil = XCTestExpectation(description: "error message reset")

        var count = 0
        viewModel.$errorMessage
            .sink { errorMessage in
                switch count {
                case 2:
                    XCTAssertNotNil(errorMessage)
                    expectationErrorMessageSetSome.fulfill()
                case 3:
                    XCTAssertNil(errorMessage)
                    expectationErrorMessageSetNil.fulfill()
                    // still should be first page
                    XCTAssertEqual(mockService.requestedPage, APIConstants.collectionFirstPage)
                default: break
                }
                count += 1
            }
            .store(in: &cancellables)

        viewModel.fetchArtObjects()

        wait(for: [expectationErrorMessageSetSome], timeout: 0.25)

        mockService.fetchArtObjectsResult = .success(
            CollectionResponse(
                count: 999,
                artObjects: [ArtObject(
                    id: "1",
                    objectNumber: "1",
                    title: "test",
                    principalOrFirstMaker: "test",
                    webImage: WebImage(guid: "1", url: "test")
                )]
            )
        )

        viewModel.fetchArtObjects()
        wait(for: [expectationErrorMessageSetNil], timeout: 0.25)
    }

    @MainActor
    func testCorrectSectionsUpdate() {
        let mockService = MockArtObjectsService()
        mockService.fetchArtObjectsResult = .success(
            CollectionResponse(
                count: 999,
                artObjects: [ArtObject(
                    id: "1",
                    objectNumber: "1",
                    title: "test",
                    principalOrFirstMaker: "test",
                    webImage: WebImage(guid: "1", url: "test")
                )]
            )
        )

        let dependencies = MockArtObjectsCollectionDependencies(artObjectsService: mockService)
        let viewModel = ArtObjectsCollectionViewModel(dependencies: dependencies)

        XCTAssertEqual(viewModel.sections.count, 0)

        let expectationSectionsSet1 = XCTestExpectation(description: "sections set 1")
        let expectationSectionsSet2 = XCTestExpectation(description: "sections set 2")

        var count = 0
        viewModel.$sections
            .sink { sections in
                switch count {
                case 1:
                    XCTAssertEqual(sections.count, 1)
                    expectationSectionsSet1.fulfill()
                    XCTAssertEqual(mockService.requestedPage, APIConstants.collectionFirstPage)
                case 2:
                    XCTAssertEqual(sections.count, 2)
                    expectationSectionsSet2.fulfill()
                    XCTAssertEqual(mockService.requestedPage, APIConstants.collectionFirstPage + 1)
                default:
                    break
                }
                count += 1
            }
            .store(in: &cancellables)

        viewModel.fetchArtObjects()
        wait(for: [expectationSectionsSet1], timeout: 0.25)

        viewModel.fetchArtObjects()
        wait(for: [expectationSectionsSet2], timeout: 0.25)
    }

}


struct MockArtObjectsCollectionDependencies: ArtObjectsViewModelDependencies {
    var artObjectsService: ArtObjectsServiceProtocol
}


final class MockArtObjectsService: ArtObjectsServiceProtocol {

    var fetchArtObjectsResult: Result<CollectionResponse, NetworkError>!
    var requestedPage = APIConstants.collectionFirstPage-1

    func fetchArtObjects(page: Int) async -> Result<CollectionResponse, NetworkError> {
        requestedPage = page
        try! await Task.sleep(nanoseconds: 500_000)
        return fetchArtObjectsResult
    }

    func fetchArtObjectDetails(objectNumber: String) async -> Result<ArtObjectDetailResponse, NetworkError> {
        fatalError()
    }
    
}
