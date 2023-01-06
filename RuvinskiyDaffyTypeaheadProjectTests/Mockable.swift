//
//  Mockable.swift
//  RuvinskiyDaffyTypeaheadProjectTests
//
//  Created by David Ruvinskiy on 1/2/23.
//

import Foundation

protocol Mockable: AnyObject {
    var bundle: Bundle  { get }
    func loadData(filename: String) -> Data
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func loadData(filename: String) -> Data {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON file.")
        }
        
        do {
            return try Data(contentsOf: path)
        } catch {
            print("❌ \(error)")
            fatalError("Failed to load the Data.")
        }
    }
}
