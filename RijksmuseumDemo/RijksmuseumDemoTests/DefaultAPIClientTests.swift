//
//  DefaultAPIClientTests.swift
//  RijksmuseumDemoTests
//
//  Created by Roman Churkin on 29/05/2023.
//

import XCTest
@testable import RijksmuseumDemo


final class DefaultAPIClientTests: XCTestCase {

    struct TestEndpoint: Endpoint {
        var path: String { "/test" }
        var httpMethod: HTTPMethod {.get}
        var queryItems: [URLQueryItem]? { nil }
        var httpBody: Data? { nil }
    }

    func testSuccessCollectionRequest() async {
        let mockURLSession = MockURLSession()
        let apiClient = DefaultAPIClient(session: mockURLSession)
        let testEndpoint = TestEndpoint()
        let urlComponents = URLComponents(endpoint: testEndpoint)
        let url = urlComponents.url!

        let expectedData = """
        {
            "count": 999,
            "artObjects": [{
                "id": "en-RP-T-1891-A-2471",
                "objectNumber": "RP-T-1891-A-2471",
                "title": "View of a Richly Appointed Chamber with a Four-poster Bed",
                "principalOrFirstMaker": "Adriaen Pietersz van de Venne",
                "webImage": {
                    "guid": "eec2fb7d-1421-4d42-a618-20f0f538db14",
                    "url": "https://lh5.ggpht.com/hyGAjfIw5Q5dtHhd2ZmqWmE6tazx036TKVwFlGwqACdh8Z1nDsLNn8zokc-_DlJwabOMI_OOgrZAZqRRojQTefOv_Nw=s0"
                }
            }]
        }
        """.data(using: .utf8)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.mockResponse = (expectedData, httpResponse, nil)

        let result = await apiClient.sendRequest(testEndpoint, ofType: CollectionResponse.self)
        switch result {
        case .success(let response):
            XCTAssertEqual(response.count, 999)
            XCTAssertEqual(response.artObjects.count, 1)
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testFailOnIncorrectResponse() async {
        let mockURLSession = MockURLSession()
        let apiClient = DefaultAPIClient(session: mockURLSession)
        let testEndpoint = TestEndpoint()
        let urlComponents = URLComponents(endpoint: testEndpoint)
        let url = urlComponents.url!

        let expectedData = """
        {
            "no": "response",
        }
        """.data(using: .utf8)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.mockResponse = (expectedData, httpResponse, nil)

        let result = await apiClient.sendRequest(testEndpoint, ofType: CollectionResponse.self)
        switch result {
        case .success:
            XCTFail("Expected error but received success")
        case .failure:
            break
        }
    }

}

class MockURLSession: URLSessionProtocol {

    var mockResponse: (Data?, URLResponse?, Error?) = (nil, nil, nil)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            guard let data = mockResponse.0, let response = mockResponse.1 else {
                continuation.resume(throwing: mockResponse.2 ?? NetworkError.noResponse)
                return
            }
            continuation.resume(returning: (data, response))
        }
    }
}


