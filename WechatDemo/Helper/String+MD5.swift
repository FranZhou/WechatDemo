//
//  String+MD5.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import Foundation
import CommonCrypto

extension String {
    
    var fz_md5: String? {
        if let cStr = self.cString(using: .utf8) {
            let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
            let digestLen = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
            defer {
                result.deallocate()
            }
            CC_MD5(cStr, strLen, result)

            let output = NSMutableString()
            for i in 0..<digestLen {
                output.appendFormat("%02x", result[i])
            }

            return String(output)
        } else {
            return nil
        }
    }
    
}
