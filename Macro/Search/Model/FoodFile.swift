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
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("Name")
        
        // Check if file exists in Documents directory; if not, copy it from the bundle
        if !fileManager.fileExists(atPath: filePath.path) {
            guard let bundleFilePath = Bundle.main.url(forResource: "Name", withExtension: nil) else {
                assertionFailure("foods file is not in the main bundle")
                return nil
            }
            
            do {
                try fileManager.copyItem(at: bundleFilePath, to: filePath)
            } catch {
                print("Failed to copy 'Name' file from bundle to Documents directory:", error)
                return nil
            }
        }
        
        self.init(location: filePath)
    }
    
    func loadFoods() -> [String] {
        do {
            let data = try Data(contentsOf: location)
            let string = String(data: data, encoding: .utf8)
            return string?.components(separatedBy: .newlines).filter { !$0.isEmpty } ?? []
        } catch {
            print("Failed to load food names:", error)
            return []
        }
    }
    
}
