//
//  SearchLocation.swift
//  ITP312
//
//  Created by Jia Rong on 10/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit



class SearchLocation: UITextField {
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC  = MKLocalSearchCompleter()
        sC.delegate = self
        return sC
    }()
    


    var tableView: UITableView?
    var searchResults = [MKLocalSearchCompletion]()
            
    // Link table view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
            
        tableView?.removeFromSuperview()
    }
            
        // Link textfield actions to functions
        override open func willMove(toSuperview newSuperview: UIView?) {
            super.willMove(toSuperview: newSuperview)
            
            self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
            self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
            self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        }
        
        override open func layoutSubviews() {
            super.layoutSubviews()
            createSearchTableView()
        }
            
        @objc open func textFieldDidChange() {
            searchCompleter.queryFragment = self.text!
            print("changed")
            updateSearchTableView()
            tableView?.isHidden = false
            
        }
        
        @objc open func textFieldDidBeginEditing() {
            print("begin editing")
        }
        
        @objc open func textFieldDidEndEditing() {
            print("end editing")
        }
            
        // Filter datalist with text field string query
//        fileprivate func filter() {
//            let filteredList = dataList.filter{ $0.localizedCaseInsensitiveContains(self.text!) }
//            print(filteredList)
//
//            // Reset results
//            resultsList = []
//
//            // Print foreach results
//            for i in 0 ..< filteredList.count {
//                let item = SearchItem(countryName: filteredList[i])
//
//                let countryFilter = (item.countryName as NSString).range(of: text!, options: .caseInsensitive)
//
//                if (countryFilter.location != NSNotFound) {
//                    item.attributedCountryName = NSMutableAttributedString(string: item.countryName)
//
//                    item.attributedCountryName!.setAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: countryFilter)
//                }
//                resultsList.append(item.countryName)
//            }
//        }
            
            

            /*
            // Only override draw() if you perform custom drawing.
            // An empty implementation adversely affects performance during animation.
            override func draw(_ rect: CGRect) {
                // Drawing code
            }
            */

    }

    // Delegate and Datasource for TableView
    extension SearchLocation: UITableViewDelegate, UITableViewDataSource {
            
        func createSearchTableView() {
            if let tableView = tableView {
                tableView.register(UITableViewCell.self, forCellReuseIdentifier:"CustomSearchCell")
                    tableView.delegate = self
                    tableView.dataSource = self
                    self.window?.addSubview(tableView)
                } else {
                    print("TableView created")
                    tableView = UITableView(frame: CGRect.zero)
                }
                
                updateSearchTableView()
            }
            
        func updateSearchTableView() {
            if let tableView = tableView {
                superview?.bringSubviewToFront(tableView)
                var tableHeight: CGFloat = 0
                tableHeight = tableView.contentSize.height
                          
                // Set a bottom margin of 10p
                if tableHeight < tableView.contentSize.height {
                    tableHeight -= 10
                }
                          
                // Set tableView frame
                var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
                tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
                tableViewFrame.origin.x += 2
                tableViewFrame.origin.y += frame.size.height + 2
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
                    
                })
                          
                //Setting tableView style
                tableView.layer.masksToBounds = true
                tableView.separatorInset = UIEdgeInsets.zero
                tableView.layer.cornerRadius = 5.0
                tableView.separatorColor = UIColor.lightGray
                tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                          
                if self.isFirstResponder {
                    superview?.bringSubviewToFront(self)
                }
                          
                tableView.reloadData()
                
            }
        }
            
        public func numberOfSections(in tableView: UITableView) -> Int {
                return 1
        }
            
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchResults.count
        }
            
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell",for: indexPath) as UITableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.textLabel?.text = searchResult.title
            print("title: " + searchResult.title + ", subtitle: " + searchResult.subtitle)
            cell.detailTextLabel?.text = searchResult.subtitle
            return cell
        }
            
        public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("selected row")
            self.text = searchResults[indexPath.row].title
            tableView.isHidden = true
            self.endEditing(true)
        }


}

extension SearchLocation : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print(completer.results)
        let country: String? = GlobalData.shared.countryName
        if (country != nil) {
            print("country: " ,country!)
        }
        self.searchResults = completer.results.filter({ $0.title.localizedCaseInsensitiveContains(country!) || $0.subtitle.localizedCaseInsensitiveContains(country!) })
        
        
        print(self.searchResults)
        updateSearchTableView()
        tableView?.isHidden = false
    

    }
}
