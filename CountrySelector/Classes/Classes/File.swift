//
//  File.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 8/11/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import UIKit

struct File {
    static func generate(dictionaryFromFile jsonFile: String) -> Any {
        guard
            let path = Bundle.main.path(forResource: jsonFile, ofType: "json"),
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        else {
            return [:]
        }
        
        return jsonString.toResponse()
    }
}

extension String {
    func toResponse() -> Any {
        guard
            let data = self.data(using: .utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: [])
        else {
            return [:]
        }
        
        return dictionary
    }
}
