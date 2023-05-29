//
//  ArtObject.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


struct ArtObject: Decodable {

    let id: String
    let objectNumber: String
    let title: String
    let principalOrFirstMaker: String
    let webImage: WebImage

}


extension ArtObject: Hashable {

    static func == (lhs: ArtObject, rhs: ArtObject) -> Bool {
        lhs.objectNumber == rhs.objectNumber
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectNumber)
    }

}
