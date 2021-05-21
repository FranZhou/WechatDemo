//
//  UIScrollView+Refresh.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit

private struct UIScrollViewAssociatedKey {
    static var header: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "UIScrollViewAssociatedKey_header".hashValue)!
    static var footer: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "UIScrollViewAssociatedKey_footer".hashValue)!
}

extension UIScrollView {
    
    var fz_header: HeaderRefreshView? {
        get {
            let header = objc_getAssociatedObject(self, UIScrollViewAssociatedKey.header) as? HeaderRefreshView
            return header
        }
        set {
            // remove old
            self.fz_header?.removeFromSuperview()
            
            // add new
            if let view = newValue {
                self.addSubview(view)
            }
            
            objc_setAssociatedObject(self, UIScrollViewAssociatedKey.header, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fz_footer: FooterRefreshView? {
        get {
            let footer = objc_getAssociatedObject(self, UIScrollViewAssociatedKey.footer) as? FooterRefreshView
            return footer
        }
        set {
            // remove old
            self.fz_footer?.removeFromSuperview()

            // add new
            if let view = newValue {
                self.addSubview(view)
            }
            
            objc_setAssociatedObject(self, UIScrollViewAssociatedKey.footer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
}
