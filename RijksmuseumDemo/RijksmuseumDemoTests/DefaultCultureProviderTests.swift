//
//  DefaultCultureProviderTests.swift
//  RijksmuseumDemoTests
//
//  Created by Roman Churkin on 28/05/2023.
//

import XCTest
@testable import RijksmuseumDemo


class MockLocaleProvider: LocaleProvider {
    var preferredLanguages: [String] = []

    func setPreferredLanguages(_ languages: [String]) {
        self.preferredLanguages = languages
    }
}


final class DefaultCultureProviderTests: XCTestCase {

    func testCultureProvider() throws {
        let mockLocaleProvider = MockLocaleProvider()
        let cultureProvider = DefaultCultureProvider(localeProvider: mockLocaleProvider)

        mockLocaleProvider.setPreferredLanguages(["nl"])
        XCTAssertEqual(cultureProvider.culture, "nl")

        mockLocaleProvider.setPreferredLanguages(["en"])
        XCTAssertEqual(cultureProvider.culture, "en")

        mockLocaleProvider.setPreferredLanguages([])
        XCTAssertEqual(cultureProvider.culture, "nl")

        mockLocaleProvider.setPreferredLanguages(["en", "nl"])
        XCTAssertEqual(cultureProvider.culture, "en")

        mockLocaleProvider.setPreferredLanguages(["nl", "en"])
        XCTAssertNotEqual(cultureProvider.culture, "en")

        mockLocaleProvider.setPreferredLanguages(["a", "b", "c"])
        XCTAssertEqual(cultureProvider.culture, "en")
    }

}
