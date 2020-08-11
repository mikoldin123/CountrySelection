//
//  CountriesManager.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 8/11/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation

enum CountrySelectionType {
    case code
    case nationality
    case country
}

protocol CountriesManagerServices: class {
    var allCountries: [Country] { get set }
    var allNationalities: [Country] { get set }
    var allMobileCodes: [Country] { get set }
    
    func generateCountryData()
    func searchFromSelection(_ type: CountrySelectionType, withQuery query: String) -> [Country]
}

class CountriesManager: CountriesManagerServices {
    static let shared = CountriesManager()
    
    var allCountries: [Country] = []
    
    var allMobileCodes: [Country] = []
    
    var allNationalities: [Country] = []
    
    private let countryList: Any = {
        return File.generate(dictionaryFromFile: "country-list")
    }()
    
    // MARK: - Call this to generate country array
    func generateCountryData() {
        guard let countries = try? DictionaryDecoder().decode([Country].self, from: countryList) else {
            return
        }
        
        self.allCountries = countries
        
        self.allNationalities = countries.sorted(by: { $0.nationality < $1.nationality })
        
        self.allMobileCodes = countries.filter({ !$0.phoneCode.isEmpty })
    }
    
    func searchFromSelection(_ type: CountrySelectionType, withQuery query: String) -> [Country] {
        switch type {
        case .nationality:
            return allNationalities.filter({($0.nationality.lowercased()).contains(query.lowercased())})
        case .code:
            return allMobileCodes.filter({($0.phoneCode.lowercased()).contains(query.lowercased()) || ($0.name.lowercased()).contains(query.lowercased())})
        default:
            return allCountries.filter({($0.name.lowercased()).contains(query.lowercased())})
        }
    }
}
