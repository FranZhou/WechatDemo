//
//  WechatMomentsTweetsCell.swift
//  WechatDemo
//
//  Created by FranZhou on 2021/5/20.
//

import UIKit

class WechatMomentsTweetsCell: UITableViewCell {
    
    public static var oneImageSize: CGSize = {
        let moreImageSize = WechatMomentsTweetsCell.moreImageSize
        return CGSize(width: moreImageSize.width, height: moreImageSize.height * 1.4)
    }()
    
    public static var moreImageSize: CGSize = {
        let minScreenWidth = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let width = (minScreenWidth - (16.0 + 40.0 + 8.0 + 16.0 + 16.0 * 2)) / 3.0
        let floorfWidth = floor(width)
        return CGSize(width: floorfWidth, height: floorfWidth)
    }()
    
    /// cell model
    var model: UserTweetsModel? = nil
    
    lazy var nickLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.textColor = .white
        label.textColor = .black
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        return imageView
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
//        label.textColor = .white
        label.textColor = .black
        return label
    }()
    
    /// tweets images collectionView layput
    lazy var imagesLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 16
//        layout.itemSize = WechatMomentsTweetsCell.oneImageSize()
        
        return layout
    }()
    
    /// tweets images collectionView
    lazy var imagesView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.imagesLayout)
        collectionView.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))

         return collectionView
    }()
    
    /// tweets comments
    lazy var commentsView: WechatMomentsCommentsView = {
       let view = WechatMomentsCommentsView()
        return view
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
        
        self.avatarImageView.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.left.equalTo(16)
            maker.width.height.equalTo(40)
            maker.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-10)
        }
        
        self.nickLabel.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.avatarImageView.snp.centerY).offset(-4)
            maker.left.equalTo(self.avatarImageView.snp.right).offset(8)
        }
        
        self.contentLabel.snp.makeConstraints { maker in
            maker.left.equalTo(self.avatarImageView.snp.right).offset(8)
            maker.right.equalTo(-16)
            maker.top.equalTo(self.avatarImageView.snp.centerY).offset(4)
            maker.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-10)
        }
        
    }

}


extension WechatMomentsTweetsCell {
    
    private func setupUI() {
        self.separatorInset = .zero

        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.nickLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.imagesView)
        self.contentView.addSubview(self.commentsView)
        
        self.setNeedsUpdateConstraints()
    }
    
    public func updateCell(with model: UserTweetsModel) {
        self.model = model
        
        self.nickLabel.text = model.sender?.nick ?? ""
        
        self.contentLabel.text = model.content ?? ""
        self.contentLabel.sizeToFit()
        
        // change layput itemSize
        if let images = model.images {
            if images.count == 1 {
                self.imagesLayout.itemSize = WechatMomentsTweetsCell.oneImageSize
            } else {
                self.imagesLayout.itemSize = WechatMomentsTweetsCell.moreImageSize
            }
        }
        self.imagesView.collectionViewLayout = self.imagesLayout
        self.imagesView.reloadData()
        
        // imagesView 和 commentsView
        var lastView: UIView? = self.nickLabel
        if let content = model.content,
           content.count > 0{
            lastView = self.contentLabel
        }
        
        
        if let images = model.images,
           images.count > 0{
            
            self.imagesView.snp.remakeConstraints { maker in
                maker.top.equalTo(lastView!.snp.bottom).offset(8)
                maker.left.equalTo(self.avatarImageView.snp.right).offset(8)
                maker.right.equalTo(-16)
                maker.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-10)
                maker.height.equalTo(WechatMomentsTweetsCell.collectionViewHeight(totalCount: self.model?.images?.count ?? 0))
            }
            
            lastView = self.imagesView
        } else {
            self.imagesView.snp.removeConstraints()
        }

        self.commentsView.reloadComments(self.model?.comments)
        
        if let comments = self.model?.comments,
           comments.count > 0{
            self.commentsView.snp.remakeConstraints { maker in
                maker.top.equalTo(lastView!.snp.bottom).offset(8)
                maker.left.equalTo(self.avatarImageView.snp.right).offset(8)
                maker.right.equalTo(-16)
                maker.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-10)
            }
        } else {
            self.commentsView.snp.removeConstraints()
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
    }
    
}

extension WechatMomentsTweetsCell {
    
    public static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    /// 计算图片展示collectionView的高度
    /// - Parameter totalCount: 要展示的图片
    /// - Returns: CGFloat
    public static func collectionViewHeight(totalCount: Int) -> CGFloat{
        if totalCount == 0 {
            return 0
        } else if totalCount == 1 {
            return WechatMomentsTweetsCell.oneImageSize.height
        } else {
            let minScreenWidth = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            let collectionWidth = minScreenWidth - (16.0 + 40.0 + 8.0 + 16.0) + 16.0
            let itemWidth = WechatMomentsTweetsCell.moreImageSize.width
            let rowCount: Int = Int(collectionWidth / (itemWidth + 16))
            let sectionCount = totalCount / rowCount
            return WechatMomentsTweetsCell.moreImageSize.height * CGFloat(sectionCount) + 16 * (CGFloat(sectionCount) - 1)
        }
    }
    
}


extension WechatMomentsTweetsCell: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        cell.contentView.backgroundColor = .red
        
        return cell
    }
    
    
}

extension WechatMomentsTweetsCell: UICollectionViewDelegate{
        
}
