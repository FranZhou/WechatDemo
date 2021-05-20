//
//  UserInfoModel.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import Foundation

/// user info
/// data from: https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith
struct UserInfoModel: Codable {
    
    var profile_image: String?
    
    var avatar: String?
    
    var nick: String?
    
    var username: String?
    
    // profile-image -> profile_image
    private enum CodingKeys: String, CodingKey {
        case profile_image = "profile-image"
        case avatar
        case nick
        case username
    }
    
}
