//
//  Endpoint.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 1/3/23.
//

import Foundation

enum Endpoint {
    case categories
    case meals(category: String)
    case details(id: String)
    
    var url: URL? {
        switch self {
        case .categories:
            return .makeForEndpoint("categories.php")
        case .meals(let category):
            return .makeForEndpoint("filter.php?c=\(category)")
        case .details(let id):
            return .makeForEndpoint("lookup.php?i=\(id)")
        }
    }
}
