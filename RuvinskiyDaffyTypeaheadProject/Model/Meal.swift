//
//  Meal.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/17/22.
//

import Foundation

struct MealResponse: Codable {
    let meals: [Meal]
}

struct Meal: Codable, Hashable, Comparable, Equatable {
    let name: String
    let thumbnailUrl: String
    let id: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name).trimmingCharacters(in: .whitespaces)
        thumbnailUrl = try values.decode(String.self, forKey: .thumbnailUrl)
        id = try values.decode(String.self, forKey: .id)
    }
    
    init(name: String, thumbnailUrl: String, id: String) {
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.id = id
    }
    
    init(id: String) {
        self.name = ""
        self.thumbnailUrl = ""
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case thumbnailUrl = "strMealThumb"
        case id = "idMeal"
    }
    
    static func < (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func filter(meals: [Meal], filter: String) -> [Meal] {
        return meals.filter { $0.name.lowercased().contains(filter.lowercased() ) }
    }
    
    static func getSampleMeals() -> [Meal] {
        return [
            Meal(name: "Beef and Mustard Pie",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg",
                 id: "52874"),
            
            Meal(name: "Beef and Oyster pie",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/wrssvt1511556563.jpg",
                 id: "52878"),
            
            Meal(name: "Beef Banh Mi Bowls with Sriracha Mayo, Carrot & Pickled Cucumber",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/z0ageb1583189517.jpg",
                 id: "52997"),
            
            Meal(name: "Ayam Percik",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/020z181619788503.jpg",
                 id: "53050"),
            
            Meal(name: "Brown Stew Chicken",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/sypxpx1515365095.jpg",
                 id: "52940"),
            
            Meal(name: "Chick-Fil-A Sandwich",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/sbx7n71587673021.jpg",
                 id: "53016"),
            
            Meal(name: "Apam balik",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
                 id: "53049"),
            
            Meal(name: "Apple & Blackberry Crumble",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
                 id: "52893"),
            
            Meal(name: "Apple Frangipan Tart",
                 thumbnailUrl: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg",
                 id: "52768")
        ]
    }
}
