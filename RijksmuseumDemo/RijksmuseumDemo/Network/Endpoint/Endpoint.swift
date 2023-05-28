//
//  Endpoint.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


enum HTTPMethod: String {
    case get = "GET"
}


protocol Endpoint{

    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var httpMethod: HTTPMethod { get }
    var httpBody: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}


extension Endpoint {

    /*

     Rijksmuseum API defaults.
     Hardcoded for demonstration

     */

    var scheme: String { "https" }
    var host: String { "www.rijksmuseum.nl" }
    var headers: [String: String]? { ["Content-Type": "application/json"] }

}
