//
//  Country.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 12/03/201.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import UIKit

struct Country: Codable {
    var alphaCode2: String = ""
    var alphaCode3: String = ""
    
    var name: String = ""
    var nationality: String = ""
    
    var phoneCode: String = ""

    var flag: UIImage? {
        return UIImage(named: "country-flags.bundle/Images/\(alphaCode2.uppercased())",
            in: Bundle(for: CountriesViewController.self),
            compatibleWith: nil)!
    }
    
    enum CodingKeys: String, CodingKey {
        case alphaCode2 = "alpha_2_code"
        case alphaCode3 = "alpha_3_code"
        case name = "en_short_name"
        case nationality
        case phoneCode = "country_code"
    }
}
