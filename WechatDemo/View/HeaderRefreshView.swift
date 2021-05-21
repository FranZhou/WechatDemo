//
//  HeaderRefreshView.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/21.
//

import UIKit

class HeaderRefreshView: RefreshView {
        
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        return activityIndicatorView
    }()
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentOffset",
           let scrollView = self.getSuperScrollview(){
            
            // 定义偏移临界值
            let criticalValue = -self.refreshHeight
            
            // 当前偏移的大小
            let contentOffsetY = scrollView.contentOffset.y
            
            // 判断用户是否在拖动中
            if scrollView.isDragging {
                
                // 拖动中
                if contentOffsetY >= criticalValue && self.refreshType == .pulling {
                    // 当 偏移量 >= 临界值, 代表向下拉的距离没超过临界值, 且当前状态为 下拉中, 这是要切换状态为 -> 正常中
                    self.refreshType = .normal
                } else if contentOffsetY < criticalValue && self.refreshType == .normal {
                    // 当 偏移量 < 临界值, 代表向下拉的距离更大, 且当前状态为 正常中, 这是要切换状态为 -> 下拉中
                    self.refreshType = .pulling
                }
            } else{
                // 没有拖动, 也就是松手了
                // 只关心 刷新状态为下拉中时 松开手 , 此时切换状态为 刷新中
                if self.refreshType == .pulling {
                    self.refreshType = .refreshing
                } else {

                }
            }
        }
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            self.frame = CGRect(x: 0, y: -self.refreshHeight, width: UIScreen.main.bounds.size.width, height: self.refreshHeight)
        }

    }
    
    // MARK: -
    override func refreshStatusChanged(_ refreshType: RefreshControlType) {
        switch refreshType {
            case .refreshing, .pulling:
                self.activityIndicatorView.startAnimating()
            default:
                self.activityIndicatorView.stopAnimating()
        }
    }
    
    override func prepareForUI() {
        super.prepareForUI()
        
        self.addSubview(self.activityIndicatorView)
        
        self.activityIndicatorView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.refreshHeight)
    }
    
    override public func endRefreshing() {
        super.endRefreshing()
        UIView.animate(withDuration: 0.25, animations: {
            if let scrollView = self.getSuperScrollview(){
                scrollView.contentInset.top = 0
            }
        }) { (_) in
            
        }
    }
    
}
