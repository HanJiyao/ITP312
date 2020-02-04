//
//  SearchText.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class SearchText: UITextView {
    var dataList : [String] = []
    var resultsList : [String] = []
    var tableView: UITableView?
    
    // Link table view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
      
    }
    
    @objc open func textFieldDidChange() {
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }
    
    fileprivate func filter() {
        
        // Reset results
        resultsList = []
        
        for i in 0 ..< dataList.count {
            let item = SearchItem(countryName: dataList[i])
            
            let countryFilter = (item.countryName as NSString).range(of: text!, options: .caseInsensitive)
            
            if (countryFilter.location != NSNotFound) {
                item.attributedCountryName = NSMutableAttributedString(string: item.countryName)
                
                item.attributedCountryName!.setAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: countryFilter)
            }
            resultsList.append(item.countryName)
        }
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension SearchText: UITableViewDelegate, UITableViewDataSource {
    
    func createSearchTableView() {
        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomSearchCell")
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)
        } else {
            getData()
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
            
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell", for: indexPath) as UITableViewCell
        var attributedString = NSMutableAttributedString(string: resultsList[indexPath.row])
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
        self.text = resultsList[indexPath.row]
        tableView.isHidden = true
        self.endEditing(true)
    }
    
    func getData() {
        for code in NSLocale.isoCountryCodes {
            let cID = NSLocale.localeIdentifier(fromComponents: [ NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: cID)
            dataList.append(name!)
        }
    }
    
    
}


