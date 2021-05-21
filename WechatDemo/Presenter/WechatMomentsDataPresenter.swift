//
//  WechatMomentsDataPresenter.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit
import Alamofire



/// handler wechat moment  data resquest
class WechatMomentsDataPresenter: NSObject {
    
    /// current pageNO for tweets
    private var pageNO = 1
    
    /// pageSize for tweets
    private let pageSize = 5
    
    /// tweets cache, don't request more times
    private var finishLoadTweets = false
    private var userTweets: [UserTweetsModel] = []
    
    /// singleton decoder
    private lazy var decoder = JSONDecoder()
    
    
    
    // MARK: - net work request
    
    /// 网络请求发起位置
    /// - Parameters:
    ///   - urlString: url
    ///   - params: parameters
    ///   - modelType: modelType
    ///   - callback: callback
    private func request<T: Codable>(urlString: String, parameters: [String: Any]? = nil, modelType: T.Type, callback: @escaping (_ model: T?, _ error: Error?) -> Void) {
        AF.request(URL(string: urlString)!, parameters: parameters)
            .responseJSON { [weak self] dataResponse in
                guard let `self` = self else {
                    return
                }
                switch dataResponse.result {
                    case .success(_):
                        if let resultValue = dataResponse.value{
                            do {
                                // resultValue -> jsonData -> UserInfoModel
                                let jsonData = try JSONSerialization.data(withJSONObject: resultValue, options: [])
                                let model = try self.decoder.decode(T.self, from: jsonData)
                                callback(model, nil)
                            } catch {
                                callback(nil, error)
                            }
                        } else {
                            callback(nil, NSError(domain: "WechatMomentsDataPresenter", code: 0, userInfo: ["errorMessage": "response data isn't JSON data"]))
                        }
                    case .failure(let err):
                        callback(nil, err)
                }
            }
        
    }
    
    
    // MARK: - load user info
    
    /// load wechat moment current user info
    /// - Parameter callback: callback
    func loadCurrentUserInfo(callback: @escaping (_ userInfo: UserInfoModel?, _ error: Error?) -> Void) {
        self.request(urlString: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith",
                     modelType: UserInfoModel.self) {
            (userInfo, error) in
            callback(userInfo, error)
        }
    }
    
    /// load tweets, if finishLoadTweets = true, use local cache, otherwise use request
    /// - Parameters:
    ///   - pageNO: pageNO
    ///   - callback: callback
    private func loadTweets(pageNO: Int, callback: @escaping (_ tweets: [UserTweetsModel]?, _ error: Error?) -> Void) {
        if !finishLoadTweets {
            // need request remote
            
            self.request(urlString: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith/tweets",
                         parameters: ["pageNO": pageNO, "pageSize": self.pageSize],
                         modelType: [UserTweetsModel].self) {
                [weak self] (userTweets, error) in
                guard let `self` = self else {
                    return
                }
                if let userTweets = userTweets{
                    // local cache and request finish status
                    self.userTweets = self.filterUserTweets(userTweets)
                    self.finishLoadTweets = true
                    
                    let start = (pageNO - 1) * self.pageSize
                    let end = max(start,
                                  min(start + self.pageSize, userTweets.count)
                                  )
                    
                    var resultTweets: [UserTweetsModel] = []
                    if start < end{
                        resultTweets = Array(userTweets[start..<end])
                    }
                    
                    callback(resultTweets, error)

                } else {
                    self.finishLoadTweets = false
                    callback(userTweets, error)
                }
            }
            
        } else {
            // already loaded, use cache
            
            let userTweets = self.userTweets
            
            let start = (pageNO - 1) * self.pageSize
            let end = max(start,
                          min(start + self.pageSize, userTweets.count)
                          )
            
            var resultTweets: [UserTweetsModel] = []
            if start < end{
                resultTweets = Array(userTweets[start..<end])
            }
           
                        
            callback(resultTweets, nil)
            
        }
    }
    
    
    
    /// filter user tweets which exists error
    private func filterUserTweets(_ userTweets: [UserTweetsModel]) -> [UserTweetsModel]{
        return userTweets.filter { tweets in
            return tweets.error == nil
                || tweets.error!.count == 0
        }
    }
    
    
    /// reload tweets, means load pageNO = 1 and finishLoadTweets = false
    /// - Parameter callback: callback
    func reloadTweets(callback: @escaping (_ userTweets: [UserTweetsModel]?, _ error: Error?) -> Void) {
        self.pageNO = 1
        self.finishLoadTweets = false
        
        loadTweets(pageNO: self.pageNO) { userTweets, error in
            callback(userTweets, error)
        }
        
    }
    
    
    /// load next page tweets, means load pageNO + 1
    /// - Parameter callback: callback
    func loadNextPageTweets(callback: @escaping (_ tweets: [UserTweetsModel]?, _ error: Error?) -> Void) {
        self.pageNO += 1
        
        loadTweets(pageNO: self.pageNO) { userTweets, error in
            callback(userTweets, error)
        }
        
    }
    
    
}
