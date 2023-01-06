//
//  Category.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 1/2/23.
//

import Foundation

struct CategoryResponse: Decodable {
    let categories: [Category]
}

struct Category: Decodable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strCategory"
    }
}
