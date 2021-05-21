//
//  WechatMomentsCommentsView.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit

class WechatMomentsCommentsView: UIView {
    
    /// 正在使用的labels，弱引用即可
    private lazy var usedLabels: NSHashTable<UILabel> = {
        let table = NSHashTable<UILabel>(options: NSPointerFunctions.Options.weakMemory)
        return table
    }()
    
    /// 未使用的label，要强引用
    private lazy var unusedLabels: [UILabel] = []
    
    /// 界面数据
    private var comments: [UserTweetsModel]? = nil
}

extension WechatMomentsCommentsView {
    
    
    /// remove all labels and clean constraints, all create label will move to unusedLabels array
    public func removeAllLabels() {
        // 移除所有加到界面的label，记录到unusedLabels
        self.usedLabels.allObjects.forEach { label in
            // 记住要移除约束
            label.snp.removeConstraints()
            label.removeFromSuperview()
            self.unusedLabels.append(label)
        }
        self.usedLabels.removeAllObjects()
    }
    
    
    /// reload comments view
    /// - Parameter comments: comments
    public func reloadComments(_ comments: [UserTweetsModel]?) {
        self.removeAllLabels()
        self.comments = comments
        if let comments = comments,
           comments.count > 0{
            self.rebuildCommentsView()
        }
    }
    
    /// 重新搭建界面布局
    private func rebuildCommentsView(){
        var frontLabel: UILabel? = nil
        
        for index in 0..<(self.comments?.count ?? 0) {
            let comment = self.comments![index]
            let label = getLabel(with: comment)
            
            self.addSubview(label)
            self.usedLabels.add(label)
            
            label.snp.makeConstraints { maker in
                // 是否有上一个label
                if let frontLabel = frontLabel{
                    maker.top.equalTo(frontLabel.snp.bottom)
                } else {
                    maker.top.equalTo(0)
                }
                maker.left.equalTo(0)
                maker.right.equalTo(0)
                
                // 是否有下一个label
                if index == self.comments!.count - 1{
                    maker.bottom.equalTo(0)
                }
            }
            
            frontLabel = label
            
        }
    }
    
}

extension WechatMomentsCommentsView {
    
    private func getLabel(with comment: UserTweetsModel) -> UILabel{
        var label: UILabel? = nil
        
        // label复用，避免重复创建
        if self.unusedLabels.count > 0 {
            label = self.unusedLabels.removeFirst()
        }
        
        // 没有复用的label，重新创建
        if label == nil {
            label = UILabel()
            label?.numberOfLines = 0
        }
        
        // label展示内容处理
        let attri = NSMutableAttributedString()
        if let nick = comment.sender?.nick {
            attri.append(NSAttributedString(string: "\(nick): ", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor(red: 47.0 / 255.0, green: 79.0 / 255.0, blue: 79.0 / 255.0, alpha: 1)
            ]))
        }
        
        if let content = comment.content {
            attri.append(NSAttributedString(string: content, attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]))
        }
        label?.attributedText = attri
        
        return label!
    }
    
}
