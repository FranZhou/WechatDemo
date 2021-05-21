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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
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
            maker.top.equalTo(-50)
            maker.centerX.equalTo(self.contentView.snp.centerX)
            maker.width.height.equalTo(profileWH)
            maker.bottom.equalTo(-30)
        }
        
        self.avatarImageView.snp.makeConstraints { maker in
            maker.bottom.equalTo(-10)
            maker.right.equalTo(self.profileImageView.snp.right).offset(-16)
            maker.width.height.equalTo(70)
        }
        
        self.nickLabel.snp.makeConstraints { maker in
            maker.right.equalTo(self.avatarImageView.snp.left).offset(-20)
            maker.bottom.equalTo(self.avatarImageView.snp.centerY)
        }
    }
}

extension WechatMomentsUserInfoCell {
    
    private func setupUI() {
        self.separatorInset.left = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)

        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.profileImageView)
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.nickLabel)
        
        self.setNeedsUpdateConstraints()
    }
    
    public func updateCell(with model: UserInfoModel) {
        
        self.profileImageView.fz_setImage(with: model.profile_image)
        
        self.nickLabel.text = model.nick ?? ""
        
        self.avatarImageView.fz_setImage(with: model.avatar)
    }
}


extension WechatMomentsUserInfoCell {
    
    public static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
}
