//
//  WechatMomentsUserInfoCell.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit
import SnapKit

class WechatMomentsUserInfoCell: UITableViewCell {

    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    lazy var nickLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let profileWH = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        
        self.profileImageView.snp.makeConstraints { maker in
            maker.top.equalTo(0)
            maker.centerX.equalTo(self.contentView.snp.centerX)
            maker.width.height.equalTo(profileWH)
            maker.bottom.equalTo(-30)
        }
    }
}

extension WechatMomentsUserInfoCell {
    
    private func setupUI(){
        
    }
    
}
