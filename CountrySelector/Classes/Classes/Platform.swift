//
//  Platform.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 27/06/2018.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import UIKit

struct Platform {
    
    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }()
    
    static let isIphoneX: Bool = {
        guard UIScreen.main.nativeBounds.height >= 2436 else {
            return false
        }
        
        if Platform.isIpad == true {
            return false
        }
    
        return true
    }()
    
    static let isIpad: Bool = {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return false
        }
        return true
    }()
}

extension UISearchBar {
    var textField: UITextField? {
        return subviews.map { $0.subviews.first(where: { $0 is UITextInputTraits}) as? UITextField }
            .compactMap { $0 }
            .first
    }
}
