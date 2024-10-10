//
//  FoodCache.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import Foundation

protocol FoodSource {

    func loadFoods() -> [String]
    
}

actor FoodCache {

    let source: FoodSource

    init(source: FoodSource) {
        self.source = source
    }

    var foods: [String] {
        if let foods = cachedFoods {
            return foods
        }

        let foods = source.loadFoods()
        cachedFoods = foods

        return foods
    }

    private var cachedFoods: [String]?
    
}

extension FoodCache {

    func lookup(prefix: String) -> [String] {
        foods.filter { $0.hasCaseAndDiacriticInsensitivePrefix(prefix) }
    }
    
}

extension String {

    func hasCaseAndDiacriticInsensitivePrefix(_ prefix: String) -> Bool {
        guard let range = self.range(of: prefix, options: [.caseInsensitive, .diacriticInsensitive]) else {
            return false
        }

        return range.lowerBound == startIndex
    }
    
}
