//
//  SearchItem.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class SearchItem: NSObject {
    var attributedCountryName: NSMutableAttributedString?
    var allAttributedName: NSMutableAttributedString?
    var countryName: String
    
    public init(countryName: String) {
        self.countryName = countryName
    }
    
    public func getFormatedText() -> NSMutableAttributedString {
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedCountryName!)
        return allAttributedName!
    }
    public func getStringText() -> String {
        return countryName
    }
}
