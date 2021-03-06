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
        
        // ???????????????????????????????????????????????????
        self.prepareForUI()
    }
    
    deinit {
        self.removeKVO(for: self.superview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutForUI()
    }
    
    // MARK: - override ?????????????????????????????????
    
    /// UI
    public func prepareForUI(){
        
    }
    
    /// UI????????????
    public func layoutForUI(){
    }
    
    
    /// ??????????????????
    /// - Parameter refreshType: refreshType
    public func refreshStatusChanged(_ refreshType: RefreshControlType){
        
    }
    
    
    /// ????????????
    public func endRefreshing() {
        self.refreshType = .normal
        
    }
    
}

extension RefreshView {
    
    
    /// ??????????????????????????????UIScrollView
    /// - Returns: UIScrollView?
    internal func getSuperScrollview() -> UIScrollView?{
        if let scrollView = self.superview as? UIScrollView{
            return scrollView
        }
        return nil
    }
    
    
    /// ?????????scrollview????????????kvo
    /// - Parameter view: view as? UIScrollView
    internal func addKVO(for view: UIView?){
        if let scrollView = view as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new], context: nil)
        }
    }
    
    /// ?????????scrollview????????????kvo
    /// - Parameter view: view as? UIScrollView
    internal func removeKVO(for view: UIView?) {
        if let scrollView = view as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
}
