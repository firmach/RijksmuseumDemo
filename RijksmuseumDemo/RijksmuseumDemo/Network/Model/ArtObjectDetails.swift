//
//  ArtObjectDetails.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


struct ArtObjectDetails: Decodable, Equatable {

    struct Color: Codable, Equatable {
        let percentage: Int
        let hex: String
    }

    let id: String
    let objectNumber: String
    let description: String?
    let webImage: WebImage
    let longTitle: String
    let subTitle: String
    let colors: [Color]
    let principalMaker: String

}
