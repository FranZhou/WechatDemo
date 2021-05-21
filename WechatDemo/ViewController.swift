//
//  ViewController.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/19.
//

import UIKit

class ViewController: UIViewController {
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // 有导航栏时不要自动下移
        if #available(iOS 11.0, *){
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(WechatMomentsUserInfoCell.self, forCellReuseIdentifier: WechatMomentsUserInfoCell.reuseIdentifier())
        tableView.register(WechatMomentsTweetsCell.self, forCellReuseIdentifier: WechatMomentsTweetsCell.reuseIdentifier())
        
        tableView.fz_header = HeaderRefreshView(refreshBlock: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.reloadPageData()
        })
        
        tableView.fz_footer = FooterRefreshView(refreshBlock: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.loadNextPageData()
        })
        
        return tableView
    }()
    
    /// deinit block
    lazy var deinitClosure: [() -> Void] = []
    
    /// data presenter
    lazy var dataPresenter = WechatMomentsDataPresenter()
    
    /// current user info
    var userInfo: UserInfoModel?
    
    /// tweets to display
    var userTweets: [UserTweetsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.setupUI()
        self.reloadPageData()
        
        self.addKVO()
    }
    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(0)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            self.navigationBarAlphaStatusChange()
        }
    }
    
    deinit {
        deinitClosure.forEach { closure in
            closure()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarAlphaStatusChange()
    }
    
}

extension ViewController {
    
    
    /// tableView kvo for contentOffset
    private func addKVO() {
        self.tableView.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new], context: nil)
        
        deinitClosure.append { [weak self] in
            guard let `self` = self else {
                return
            }
            self.tableView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    
    /// 导航栏变化
    private func navigationBarAlphaStatusChange(){
        let offsetY = self.tableView.contentOffset.y
        let profileWH = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        
        self.navigationController?.navigationBar.isHidden = (offsetY >= profileWH ? false : true)
    }
    
}

extension ViewController {
    
    
    /// 加载界面UI
    private func setupUI() {
        self.view.addSubview(self.tableView)
        
        self.navigationBarAlphaStatusChange()
    }
    
    
    /// 加载第一页数据
    private func reloadPageData() {
        
        // 加载当前用户信息
        self.dataPresenter.loadCurrentUserInfo { [weak self] userInfo, error in
            guard let `self` = self else {
                return
            }
            
            self.tableView.fz_header?.endRefreshing()
            
            if let userInfo = userInfo {
                
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.userInfo = userInfo
                    self.tableView.reloadData()
                }
                
            } else if let _ = error {
                
            }
        }
        
        // 加载第一页消息，必须有当前用户消息才能进行界面刷新
        self.dataPresenter.reloadTweets { [weak self] userTweets, error in
            guard let `self` = self else {
                return
            }
            
            if let userTweets = userTweets {
                if let _ = self.userInfo {
                    // 用户消息加载，第一页朋友圈数据加载，可以刷新
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        self.userTweets.removeAll()
                        self.userTweets.append(contentsOf: userTweets)
                        self.tableView.reloadData()
                    }
                } else {
                    self.userTweets.removeAll()
                    self.userTweets.append(contentsOf: userTweets)
                }
            }
        }
        
    }
    
    private func loadNextPageData() {
        self.dataPresenter.loadNextPageTweets {  [weak self] userTweets, error in
            guard let `self` = self else {
                return
            }
            
            self.tableView.fz_footer?.endRefreshing()
            
            if let userTweets = userTweets {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.userTweets.append(contentsOf: userTweets)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}


extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // section = 0  &&  userInfo
            if let _ = self.userInfo{
                return 1
            }
            return 0
        } else {
            return self.userTweets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            let cell: WechatMomentsUserInfoCell = tableView.dequeueReusableCell(withIdentifier: WechatMomentsUserInfoCell.reuseIdentifier(), for: indexPath) as! WechatMomentsUserInfoCell
            cell.updateCell(with: self.userInfo!)
            return cell
            
        } else {
            if row < self.userTweets.count {
                let tweets = self.userTweets[row]
                
                let cell: WechatMomentsTweetsCell = tableView.dequeueReusableCell(withIdentifier: WechatMomentsTweetsCell.reuseIdentifier(), for: indexPath) as! WechatMomentsTweetsCell
                cell.updateCell(with: tweets)
                return cell
            }
        }
        return UITableViewCell.init()
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}
