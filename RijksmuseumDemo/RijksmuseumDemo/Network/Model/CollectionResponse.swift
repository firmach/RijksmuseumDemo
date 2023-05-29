//
//  CollectionResponse.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


struct CollectionResponse: Decodable, Equatable {

    let count: Int
    let artObjects: [ArtObject]

    enum CodingKeys: String, CodingKey {
        case count
        case artObjects
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decode(Int.self, forKey: .count)
        var artObjectsContainer = try container.nestedUnkeyedContainer(forKey: .artObjects)
        var artObjects = [ArtObject]()
        while !artObjectsContainer.isAtEnd {
            if let artObject = try? artObjectsContainer.decode(ArtObject.self) {
                artObjects.append(artObject)
            } else {
                /*
                 I've noticed some inconsistencies in the Rijksmuseum API.
                 For instance, the items returned in the response array may not align with the requested filter.
                 Additionally, an item with a `webImage` property in the collection response
                 may not include it in the details response.
                 To make working with this API simpler, when parsing the collection response,
                 I simply ignore items that do not conform to the required model.
                 */
                _ = try? artObjectsContainer.decode(Dummy.self)
            }
        }
        self.artObjects = artObjects
    }

    init(
        count: Int,
        artObjects: [ArtObject]
    ) {
        self.count = count
        self.artObjects = artObjects
    }

    private struct Dummy: Decodable {}
}
