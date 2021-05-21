//
//  NetworkManager.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/21.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    
    public static let manager = NetworkManager()
    
    /// singleton decoder
    private lazy var decoder = JSONDecoder()

}


extension NetworkManager {
    
    public func request<T: Codable>(
        urlString: String,
        method: String = "get",
        parameters: [String: Any]? = nil,
        callback: ((_ model: T?, _ error: Error?) -> Void)? = nil
    ) {
        
        var _method = HTTPMethod.get
        if method == "post" {
            _method = .post
        }
        
        AF.request(URL(string: urlString)!, method: _method, parameters: parameters)
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
                                callback?(model, nil)
                            } catch {
                                callback?(nil, error)
                            }
                        } else {
                            callback?(nil, NSError(domain: "NetworkManager", code: 0, userInfo: ["errorMessage": "response data isn't JSON data"]))
                        }
                    case .failure(let err):
                        callback?(nil, err)
                }
            }
        
        
    }
    
    
    public func download(
        urlString: String,
        progressHandler: ((_ progress: Progress) -> Void)? = nil,
        callback: ((_ data: Data?, _ error: Error?) -> Void)? = nil
    ){
        // 网络下载
        AF.download(urlString)
            .downloadProgress(closure: { progress in
                progressHandler?(progress)
            })
            .responseData { dataResponse in
                if let data = dataResponse.value {
                  callback?(data, nil)
                } else {
                    if let err = dataResponse.error {
                        callback?(nil, err)
                    } else {
                        callback?(nil, NSError(domain: "NetworkManager", code: 0, userInfo: ["errorMessage": "response data isn't JSON data"]))
                    }
                }
            }
        
    }
    
    
    
    
}
