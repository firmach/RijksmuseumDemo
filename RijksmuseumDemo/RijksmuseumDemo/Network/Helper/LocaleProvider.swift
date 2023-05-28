//
//  LocaleProvider.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 28/05/2023.
//

import Foundation


protocol LocaleProvider {
    var preferredLanguages: [String] { get }
}


struct DefaultLocaleProvider: LocaleProvider {
    var preferredLanguages: [String] { Locale.preferredLanguages }
}
