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
