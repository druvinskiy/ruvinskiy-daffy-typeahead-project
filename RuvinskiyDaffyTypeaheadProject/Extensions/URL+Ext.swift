//
//  URL+Ext.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 1/3/23.
//

import Foundation

extension URL {
    static func makeForEndpoint(_ endpoint: String) -> URL? {
        URL(string: "https://www.themealdb.com/api/json/v1/1/\(endpoint)")
    }
}
