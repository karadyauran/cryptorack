//
//  CoinType.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import Foundation

enum CoinType: String, Identifiable, CaseIterable {
    case bitcoin
    case ethereum
    case monero
    case litecoin
    case dogecoin
    
    var id: Self {self}
    var url: URL {URL(string: "https://coincap.io/assets/\(rawValue)")!}
    var description: String {rawValue.capitalized}
}
