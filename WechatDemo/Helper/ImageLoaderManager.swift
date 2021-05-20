//
//  ImageLoaderManager.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit
import Alamofire

class ImageLoaderManager: NSObject {
    
    static let manager: ImageLoaderManager = ImageLoaderManager()
    
    /// 图片缓存地址目录
    static let cacheDirectory: String = "WechatDemo"
    
    /// 内存缓存
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 30
        return cache
    }()
    
    
    /// 多线程队列： 读写锁，读取缓存图片时不加锁，保存图片至缓存时使用栅栏
    private lazy var imageSearchQueue = DispatchQueue(label: "com.franzhou.WechatDemo.ImageLoaderManager", attributes: DispatchQueue.Attributes.concurrent)
    
}

extension ImageLoaderManager {
    
    public func imageForUrl(urlString: String, callback: @escaping (_ image: UIImage?, _ url: String) -> Void) {
        // 异步获取图片
        self.memoryImageForUrl(urlString: urlString, callback: callback)
    }
    
}

extension ImageLoaderManager {
    
    
    /// 获取缓存图片:  内存查找 -> 磁盘查找 -> 网络下载
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - callback: callback
    private func memoryImageForUrl(urlString: String, callback:@escaping (_ image: UIImage?, _ url: String) -> Void) {
        
        // 异步获取图片
        self.imageSearchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // 从缓存中取
            let image = self.imageCache.object(forKey: urlString as NSString)
            
            // 缓存中存在直接去除并在主线程返回
            if let image = image {
                DispatchQueue.main.async {
                    callback(image, urlString)
                }
            } else {
                // 缓存中没有
                self.diskImageForUrl(urlString: urlString, callback: callback)
            }
            
        }
        
    }
    
    /// 获取缓存图片:  磁盘查找 -> 网络下载
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - callback: callback
    private func diskImageForUrl(urlString: String, callback:@escaping (_ image: UIImage?, _ url: String) -> Void) {
        
        // 异步获取磁盘图片
        self.imageSearchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // 从磁盘取
            // cache path
            if let filePath = self.cacheFilePath(for: urlString) {
                if let image = UIImage(contentsOfFile: filePath) {
                    callback(image, urlString)
                    
                    // 从磁盘获取到图片之后，只需要缓存到内存即可
                    self.cache(image: image, for: urlString, toDisk: false)
                    return
                }
            }
            
            self.downloadImage(with: urlString, callback: callback)
            
        }
        
    }
    
    
    /// 获取缓存图片:   网络下载，查找完成后需要进行缓存流程
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - callback: callback
    private func downloadImage(with urlString: String, callback:@escaping (_ image: UIImage?, _ url: String) -> Void) {
        
        // 下载图片
        self.imageSearchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // 网络下载
            AF.download(urlString)
                .downloadProgress(closure: { progress in
                    debugPrint(progress)
                })
                .responseData { [weak self] dataResponse in
                    guard let `self` = self else {
                        return
                    }
                    if let data = dataResponse.value,
                       let image = UIImage(data: data)
                    {
                        callback(image, urlString)
                        
                        // cache image to memory and disk
                        self.cache(image: image, for: urlString)
                    } else {
                        callback(nil, urlString)
                    }
                }
            
        }
        
    }
    
    
    /// cache image to cache and disk
    /// - Parameters:
    ///   - image: image
    ///   - urlString: urlString
    ///   - toMemory: toMemory，default is true
    ///   - toDisk: toDisk，default is true
    private func cache(image: UIImage, for urlString: String, toMemory: Bool = true, toDisk: Bool = true) {
        // 保存cache
        self.imageSearchQueue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else {
                return
            }
            // 保存到缓存
            if toMemory {
                self.imageCache.setObject(image, forKey: urlString as NSString)
            }
            
            // 保存到文件
            if toDisk{
                if let filePath = self.cacheFilePath(for: urlString){
                    if let data = image.pngData() {
                        try? data.write(to: URL(fileURLWithPath: filePath))
                    } else if let data = image.jpegData(compressionQuality: 0){
                        try? data.write(to: URL(fileURLWithPath: filePath))
                    }
                }
            }
            
        }
        
    }
    
    /// image cache file full path
    /// - Parameter urlString: urlString
    /// - Returns: filePath
    private func cacheFilePath(for urlString: String) -> String? {
        
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            
            var url = URL(fileURLWithPath: path)
            url.appendPathComponent(ImageLoaderManager.cacheDirectory, isDirectory: true)
            
            let fileManager = FileManager.default
            let directoryPath = url.path
            
            let isDirectory = UnsafeMutablePointer<ObjCBool>.allocate(capacity: MemoryLayout<ObjCBool>.size)
            if fileManager.fileExists(atPath: directoryPath, isDirectory: isDirectory) {
                if !isDirectory.pointee.boolValue {
                    try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                }
            } else {
                try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            
            url.appendPathComponent(urlString.fz_md5 ?? urlString, isDirectory: false)
            
            return url.path
        }
        
        return nil
        
    }
    
}
