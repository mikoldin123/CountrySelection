//
//  ViewController.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 8/11/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var showCountry: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return button
    }()
    
    lazy var showNationality: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            button.topAnchor.constraint(equalTo: self.showCountry.bottomAnchor, constant: 16.0),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return button
    }()
    
    lazy var showCountryCode: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            button.topAnchor.constraint(equalTo: self.showNationality.bottomAnchor, constant: 16.0),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return button
    }()

    var countryManager: CountriesManagerServices {
        return CountriesManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .darkGray
        
        countryManager.generateCountryData()
        
        showCountry.tag = 0
        showCountry.setTitle("SHOW COUNTRY", for: .normal)
        showCountry.addTarget(self, action: #selector(showSelection), for: .touchUpInside)
        
        showNationality.tag = 1
        showNationality.setTitle("SHOW NATIONALITY", for: .normal)
        showNationality.addTarget(self, action: #selector(showSelection), for: .touchUpInside)
        
        showCountryCode.tag = 2
        showCountryCode.setTitle("SHOW COUNTRY CODE", for: .normal)
        showCountryCode.addTarget(self, action: #selector(showSelection), for: .touchUpInside)
    }

    @objc func showSelection(_ sender: UIButton) {
        var type: CountrySelectionType = .country
        
        switch sender.tag {
        case 0:
            type = .country
        case 1:
            type = .nationality
        default:
            type = .code
        }
        
        let controller = CountriesViewController()
        controller.delegate = self
        controller.selectionType = type
        
        let navigation = UINavigationController(rootViewController: controller)
        self.present(navigation, animated: true, completion: nil)
    }
    
}

extension ViewController: CountriesViewControllerDelegate {
    func countriesViewController(_ controller: CountriesViewController, didSelectCountry country: Country) {
        
        print("DID SELECT -------- \(country)")
        
        controller.dismiss(animated: true, completion: nil)
    }
}
