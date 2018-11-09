//
//  CustomImageView.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLStringUsedToLoadImage: String?
    
    func loadImage(from urlString: String) {
        
        self.lastURLStringUsedToLoadImage = urlString
        
        self.image = nil
        
        // Check if image has been cached
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("urlString not castable to URL"); return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error { print("Error downloading photo for userProfleGridCell: ", error); return }
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, (httpStatusCode >= 200) && (httpStatusCode <= 299) else {
                print("HTTP status code other than 2xx"); return
            }
            
            if url.absoluteString != self.lastURLStringUsedToLoadImage {
                return
            }
            
            guard let data = data else { print("No data return from loadImage()"); return }
            
            guard let image = UIImage(data: data) else { print("Unable to create UIImage from data"); return }
            
            // Cache the image to avoid dataTask later on
            imageCache[url.absoluteString] = image
            
            // Get back on main thread to update UI
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
}
