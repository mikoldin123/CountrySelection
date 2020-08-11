//
//  CountriesViewController.swift
//  CountrySelector
//
//  Created by Michael Dean Villanda on 8/11/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CountriesViewControllerDelegate: class {
    func countriesViewController(_ controller: CountriesViewController, didSelectCountry country: Country)
}

class CountriesViewController: UIViewController {
    
    lazy var searchBarView: UISearchBar = {
        let search = UISearchBar(frame: .zero)
        self.view.addSubview(search)
        
        return search
    }()
    
    var bottomAnchor: NSLayoutConstraint!
    
    lazy var countriesTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        self.view.addSubview(tableView)
        
        bottomAnchor = tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        if #available(iOS 11, *) {
            bottomAnchor = tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        }
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            bottomAnchor!
            ])
        
        return tableView
    }()
    
    private var cellIdentifier = "country_table_list_identifier"
    
    private var countryList: [Country] = [] {
        didSet {
            list.accept(countryList)
        }
    }
    
    private var list: BehaviorRelay<[Country]> = BehaviorRelay(value: [])
    
    private var disposeBag = DisposeBag()
    
    var countryManager: CountriesManagerServices {
        return CountriesManager.shared
    }
    
    var selectionType: CountrySelectionType = .country {
        didSet {
            populateArray()
        }
    }
    
    var selectedCountry: Country? = nil {
        didSet {
            navigationItem.leftBarButtonItem?.isEnabled = selectedCountry != nil
        }
    }
    
    weak var delegate: CountriesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressExit))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelecting))
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        setupKeyboardObservers()
        setupSearchBar()
        setupTableView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func setupSearchBar() {
        navigationItem.titleView = searchBarView
        
        searchBarView.placeholder = "Search"
        searchBarView.barTintColor = UIColor.white
        searchBarView.backgroundColor = UIColor.white
        searchBarView.isTranslucent = false
        searchBarView.textField?.backgroundColor = .lightGray
        searchBarView.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchBarView.rx
            .text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                if query.isEmpty {
                    self.list.accept(self.countryList)
                    return
                }
                
                let results = self.countryManager.searchFromSelection(self.selectionType, withQuery: query)
                
                self.list.accept(results)
                
            }).disposed(by: disposeBag)
    }
    
    func setupTableView() {
        countriesTable.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
        list.asObservable()
            .bind(to: countriesTable.rx.items(cellIdentifier: self.cellIdentifier, cellType: UITableViewCell.self)) { [unowned self] (_, country, cell) in

                cell.imageView?.image = country.flag
                cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
                cell.textLabel?.numberOfLines = 3
                
                switch self.selectionType {
                case .code:
                    cell.textLabel?.text = "\(country.name) (\(country.phoneCode))"
                case .nationality:
                    cell.textLabel?.text = country.nationality
                default:
                    cell.textLabel?.text = country.name
                }
                
                guard let selected = self.selectedCountry else {
                    return
                }
                
                cell.accessoryType = (selected.alphaCode2 == country.alphaCode2) ? .checkmark: .none
                
        }.disposed(by: disposeBag)
        
        countriesTable.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] (indexPath) in

                self.countriesTable.deselectRow(at: indexPath, animated: true)
                
                self.selectedCountry = self.list.value[indexPath.row]
                
                self.countriesTable.reloadData()
                
            }).disposed(by: disposeBag)
    }
    
    // MARK: -
    private func populateArray() {
        switch selectionType {
        case .code:
            countryList = countryManager.allMobileCodes
        case .nationality:
            countryList = countryManager.allNationalities
        default:
            countryList = countryManager.allCountries
        }
    }
}

@objc
extension CountriesViewController {
    
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }

        let padding: CGFloat = (Platform.isIphoneX) ? 0.0: 25.0
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height + padding), right: 0.0)
        
        countriesTable.contentInset = contentInsets
        countriesTable.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        countriesTable.contentInset = .zero
        countriesTable.scrollIndicatorInsets = .zero
    }
    
    func didPressExit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didFinishSelecting() {
        guard let country = self.selectedCountry else {
            return
        }
        
        self.delegate?.countriesViewController(self, didSelectCountry: country)
    }
}
