//
//  UserTweetsModel.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import Foundation

/// user tweets
/// https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith/tweets
struct UserTweetsModel: Codable {
    
    // MARK: - if error exist， means this model is useless，you must filter it。
    var error: String?
    
    // MARK: - error not exist
    var content: String?
    
    var images: Array<UserTweetsImageModel>?
    
    var sender: UserInfoModel?
    
    var comments: Array<UserTweetsModel>?
    
}

// tweets images
struct UserTweetsImageModel: Codable {
    
    var url: String?
    
}
