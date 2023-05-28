//
//  CollectionEndpoint.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


struct CollectionEndpoint: Endpoint {

    var path: String { "/api/\(culture)/collection" }
    var httpMethod: HTTPMethod { .get }
    var httpBody: Data? { nil }

    let apiKey: String
    let culture: String
    let page: Int

    var queryItems: [URLQueryItem]? { [
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "p", value: String(page)),

        // Hardcoded here only for demo case
        URLQueryItem(name: "imgonly", value: "True"),
        URLQueryItem(name: "type", value: "drawing"),
        URLQueryItem(name: "toppieces", value: "True"),
        URLQueryItem(name: "technique", value: "brush")
    ] }

}
