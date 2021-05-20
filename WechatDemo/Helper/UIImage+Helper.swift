//
//  UIImage+Helper.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit

extension UIImage {
    
    /// 修改图片尺寸
    ///
    /// - Parameter size: 修改尺寸
    /// - Returns:
    
    /// 修改图片尺寸
    /// - Parameter size: size
    /// - Returns: UIImage?
    public func fz_resize(withSize size: CGSize) -> UIImage? {
        // 尺寸没有发生变化
        guard self.size.equalTo(size) else {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }
    
    /// 图片加圆角
    /// - Parameter radius: 圆角的半径
    /// - Returns: UIImage?
    public func fz_cornerRadius(withRadius radius: CGFloat) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        path.close()
        path.stroke()
        path.addClip()

        self.draw(in: CGRect(origin: .zero, size: self.size))
        let cornerRadiusImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cornerRadiusImage
    }

    
}
