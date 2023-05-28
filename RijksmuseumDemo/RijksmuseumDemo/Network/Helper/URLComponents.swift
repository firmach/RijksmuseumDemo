//
//  URLComponents.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


extension URLComponents {

    init(endpoint: some Endpoint) {
        self.init()
        self.scheme = endpoint.scheme
        self.host = endpoint.host
        self.path = endpoint.path
        self.queryItems = endpoint.queryItems
    }
    
}
