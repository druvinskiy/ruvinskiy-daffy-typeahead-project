//
//  Details.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/19/22.
//

import Foundation

struct Details: Decodable {
    let name: String
    let instructions: String
    let ingredients: [Ingredient]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let meals = try values.decode([[String: String?]].self, forKey: .meals)
        let dict = meals[0]
        
        guard let name = dict["strMeal"], name != nil else {
            throw DTError.invalidData
        }
        
        self.name = name!
        
        guard let instructions = dict["strInstructions"], instructions != nil else {
            throw DTError.invalidData
        }
        
        self.instructions = instructions!
        
        var ingredients = [Ingredient]()
        
        for (key, value) in dict {
            guard key.starts(with: "strIngredient"), let value = value, !value.isEmpty, let range = key.range(of: "strIngredient") else { continue }
            
            let ingredientNumber = key[range.upperBound...]
            
            guard let ingredientMeasure = dict["strMeasure\(ingredientNumber)"], ingredientMeasure != nil else {
                throw DTError.invalidData
            }
            
            let ingredient = Ingredient(name: value.lowercased(), measurement: ingredientMeasure!)
            ingredients.append(ingredient)
        }
        
        self.ingredients = ingredients
    }
    
    enum CodingKeys: String, CodingKey {
        case meals
    }
}

struct Ingredient {
    let name: String
    let measurement: String
}
