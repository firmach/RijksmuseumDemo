//
//  ArtObjectDetailsEndpoint.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


struct ArtObjectDetailsEndpoint: Endpoint {

    var path: String { "/api/\(culture)/collection/\(objectNumber)" }
    var httpMethod: HTTPMethod { .get }
    var httpBody: Data? { nil }

    let apiKey: String
    let culture: String
    let objectNumber: String

    var queryItems: [URLQueryItem]? { [
        URLQueryItem(name: "key", value: apiKey)
    ] }

}
