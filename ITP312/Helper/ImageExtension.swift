//
//  ImageExtension.swift
//  ITP312
//
//  Created by Han Jiyao on 16/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageCache(urlString: String){
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if error != nil
            {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                let downloadedImage = UIImage(data: data!)
                imageCache.setObject(downloadedImage!, forKey: urlString as AnyObject)
                self.image = downloadedImage
            }
            }).resume()
    }
}



extension NSObject {
    func printObj(_ text: String) {
        print("\n \(text)-----------------")
        dump(self)
        print("\n end of printing-------------")
    }
}



extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    static var red: UIColor {
        return UIColor(red: 255, green: 59, blue: 48)
    }
    
    static var orange: UIColor {
        return UIColor(red: 255, green: 149, blue: 0)
    }
    
    static var yellow: UIColor {
        return UIColor(red: 255, green: 204, blue: 0)
    }
    
    static var green: UIColor {
        return UIColor(red: 76, green: 217, blue: 100)
    }
    
    static var tealBlue: UIColor {
        return UIColor(red: 90, green: 200, blue: 250)
    }
    
    static var blue: UIColor {
        return UIColor(red: 0, green: 122, blue: 255)
    }
    
    static var purple: UIColor {
        return UIColor(red: 88, green: 86, blue: 214)
    }
    
    static var pink: UIColor {
        return UIColor(red: 255, green: 45, blue: 85)
    }
    
    static let colors: [UIColor] = [.red, .orange, .yellow, .green, .tealBlue, .blue, .purple, .pink]
    
}

extension UIImage {
    
    static let names: [String] = ["argentina", "bolivia", "brazil", "chile", "costa rica", "cuba", "dominican republic", "ecuador", "el salvador", "haiti", "honduras", "mexico", "nicaragua", "panama", "paraguay", "peru", "venezuela"]
    
}

extension Array {
    
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
}
