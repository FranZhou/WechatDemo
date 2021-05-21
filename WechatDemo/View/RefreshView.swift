//
//  RefreshView.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/21.
//

import UIKit

enum RefreshControlType: String {
    case normal = "normal"
    case pulling = "pulling"
    case refreshing = "refreshing"
}

class RefreshView: UIView {
    
    var refreshHeight: CGFloat = 40
    
    var refreshBlock: (()->Void)?
    
    // MARK: -
    var refreshType: RefreshControlType = .normal{
        didSet{
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                switch self.refreshType {
                    case .normal:
                        debugPrint("normal")
                        
                    case .pulling:
                        debugPrint("pulling")
                    case .refreshing:
                        debugPrint("refreshing")
                        
                        // 在动画中设置顶部inset 否则会特别生硬, 注释掉看效果即可.
                        UIView.animate(withDuration: 0.25, animations: {
                            if let scrollView = self.getSuperScrollview(){
                                scrollView.contentInset.top = scrollView.contentInset.top + self.refreshHeight
                                
                                self.refreshBlock?()
                            }
                        }) { (_) in
                            
                        }
                }
                
                self.refreshStatusChanged(self.refreshType)
                
            }
            
        }
    }
    
    
    public init(refreshBlock:@escaping (()->Void)) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.refreshBlock = refreshBlock
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        self.removeKVO(for: self.superview)
        super.willMove(toSuperview: newSuperview)
        
        self.addKVO(for: newSuperview)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.prepareForUI()
    }
    
    deinit {
        self.removeKVO(for: self.superview)
    }
    
    
    // MARK: - override
    public func prepareForUI(){
        
    }
    
    public func refreshStatusChanged(_ refreshType: RefreshControlType){
        
        
    }
    
    public func endRefreshing() {
        self.refreshType = .normal
    }
    
}

extension RefreshView {
    
    
    /// 获取父视图，类型判断UIScrollView
    /// - Returns: UIScrollView?
    internal func getSuperScrollview() -> UIScrollView?{
        if let scrollView = self.superview as? UIScrollView{
            return scrollView
        }
        return nil
    }
    
    internal func addKVO(for view: UIView?){
        if let scrollView = view as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new], context: nil)
        }
    }
    
    internal func removeKVO(for view: UIView?) {
        if let scrollView = view as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
}
