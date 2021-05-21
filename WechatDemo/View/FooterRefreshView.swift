//
//  FooterRefreshView.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/21.
//

import UIKit

class FooterRefreshView: RefreshView {
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        return activityIndicatorView
    }()
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentOffset",
           let scrollView = self.getSuperScrollview(){
            
            self.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: UIScreen.main.bounds.size.width, height: self.refreshHeight)
            
            // 定义偏移临界值
            let criticalValue = self.refreshHeight
            
            // 当前偏移的大小
            let contentOffsetY = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
            
            // 判断用户是否在拖动中
            if scrollView.isDragging {
                
                // 拖动中
                if contentOffsetY <= criticalValue && self.refreshType == .pulling {
                    // 当 偏移量 <= 临界值, 代表向上拉的距离没超过临界值, 且当前状态为 下拉中, 这是要切换状态为 -> 正常中
                    self.refreshType = .normal
                } else if contentOffsetY > criticalValue && self.refreshType == .normal {
                    // 当 偏移量 > 临界值, 代表向上拉的距离更大, 且当前状态为 正常中, 这是要切换状态为 -> 上拉中
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
    }
    
    override func layoutForUI() {
        super.layoutForUI()
        self.activityIndicatorView.frame = CGRect(
            x: (self.frame.size.width - self.activityIndicatorView.frame.size.width) / 2.0,
            y: (self.frame.size.height - self.activityIndicatorView.frame.size.height) / 2.0,
            width: self.activityIndicatorView.frame.size.width,
            height: self.activityIndicatorView.frame.size.height
        )
    }
    
    override public func endRefreshing() {
        super.endRefreshing()
        UIView.animate(withDuration: 0.25, animations: {
            if let scrollView = self.getSuperScrollview(){
                scrollView.contentInset.top = scrollView.contentInset.top - self.refreshHeight
            }
        }) { (_) in
            
        }
    }
    
}





