//
//  UIImageView+Loader.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/21.
//

import UIKit

extension UIImageView {
    
    public func fz_setImage(with urlString: String?, placeholder image: UIImage? = nil) {
        
        if let holder = image {
            self.image = holder
        }
        
        if let urlString = urlString {
            ImageLoaderManager.manager.imageForUrl(urlString: urlString) { cacheImage, urlString in
                if let cacheImage = cacheImage {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        self.image = cacheImage
                        self.layoutIfNeeded()
                    }
                }
            }
        }
        
    }
    
}
