//
//  APIClient.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


enum NetworkError: Error {

    case invalidURL
    case noResponse
    case networkError(Error)
    case decodingError(DecodingError)
    case httpError(Int)

}


protocol APIClient {

    func sendRequest<ResponseModel: Decodable>(
        _ endpoint: Endpoint,
        ofType: ResponseModel.Type
    ) async -> Result<ResponseModel, NetworkError>

}


struct DefaultAPIClient: APIClient {

    func sendRequest<ResponseModel: Decodable>(
        _ endpoint: Endpoint,
        ofType: ResponseModel.Type
    ) async -> Result<ResponseModel, NetworkError> {
        do {
            let request = try URLRequest(endpoint: endpoint)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(ResponseModel.self, from: data)

            return .success(result)
        } catch (let error) {
            if let error = error as? DecodingError {
                return .failure(NetworkError.decodingError(error))
            } else {
                return .failure(NetworkError.networkError(error))
            }
        }
    }

}

