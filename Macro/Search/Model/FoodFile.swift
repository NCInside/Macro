//
//  FoodFile.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import Foundation

struct FoodFile: FoodSource {

    let location: URL

    init(location: URL) {
        self.location = location
    }

    init?() {
        guard let location = Bundle.main.url(forResource: "Name", withExtension: nil) else {
            assertionFailure("foods file is not in the main bundle")
            return nil
        }

        self.init(location: location)
    }

    func loadFoods() -> [String] {
        do {
            let data = try Data(contentsOf: location)
            let string = String(data: data, encoding: .utf8)
            return string?.components(separatedBy: .newlines) ?? []
        }
        catch {
            return []
        }
    }
    
}
