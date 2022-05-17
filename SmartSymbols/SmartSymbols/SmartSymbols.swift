//
//  SmartSymbols.swift
//  SmartSymbols
//
//  Created by Leonard Mehlig on 21.05.21.
//

protocol SmartSymbolRecommender {
    func symbols(for title: String, maxResults: Int) -> [(Double, String)]
}
