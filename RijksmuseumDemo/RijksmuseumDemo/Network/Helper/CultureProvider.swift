//
//  CultureProvider.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


protocol CultureProvider {
    var culture: String { get }
}


struct DefaultCultureProvider: CultureProvider {

    enum Culture {
        static let dutch = "nl"
        static let english = "en"
    }

    let localeProvider: LocaleProvider

    var culture: String {
        /*
         This is a simplified implementation that still effectively showcases the core concept and functionality.
         Improvements are certainly possible. For instance, we could enhance it
         by checking if the 'preferredLanguages' array contains Dutch (even if not as the first preference)
         and use that instead of English.
         */
        guard let preferredLanguage = localeProvider.preferredLanguages.first,
              let languageCode = Locale.Components(identifier: preferredLanguage).languageComponents.languageCode?.identifier
        else {
            return Culture.dutch
        }

        let language = languageCode.lowercased()
        return language == Culture.dutch ? Culture.dutch : Culture.english
    }

}
