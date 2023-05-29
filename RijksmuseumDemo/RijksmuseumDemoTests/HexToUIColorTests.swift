//
//  HexToUIColorTests.swift
//  RijksmuseumDemoTests
//
//  Created by Roman Churkin on 29/05/2023.
//

import XCTest
@testable import RijksmuseumDemo


final class HexToUIColorTests: XCTestCase {

    func testHexColor() {
        // Black
        let black = UIColor(hex: "000000")
        XCTAssertEqual(black, UIColor(red: 0, green: 0, blue: 0, alpha: 1))

        // White
        let white = UIColor(hex: "#FFFFFF")
        XCTAssertEqual(white, UIColor(red: 1, green: 1, blue: 1, alpha: 1))

        // Red
        let red = UIColor(hex: " #FF0000")
        XCTAssertEqual(red, UIColor(red: 1, green: 0, blue: 0, alpha: 1))

        // Green
        let green = UIColor(hex: "00FF00 ")
        XCTAssertEqual(green, UIColor(red: 0, green: 1, blue: 0, alpha: 1))

        // Blue
        let blue = UIColor(hex: "#0000FF")
        XCTAssertEqual(blue, UIColor(red: 0, green: 0, blue: 1, alpha: 1))

        // Random Color 1 - Orange
        let orange = UIColor(hex: "  FFA500")
        XCTAssertEqual(orange, UIColor(red: 1, green: 165/255, blue: 0, alpha: 1))

        // Random Color 2 - Purple
        let purple = UIColor(hex: "#800080  ")
        XCTAssertEqual(purple, UIColor(red: 128/255, green: 0, blue: 128/255, alpha: 1))
    }

    
}
