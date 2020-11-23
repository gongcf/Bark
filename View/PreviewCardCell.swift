//
//  PreviewCardCell.swift
//  Bark
//
//  Created by huangfeng on 2018/6/26.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Material

class PreviewCardCell: BaseTableViewCell {

    let previewButton = IconButton(image: Icon.cm.skipForward, tintColor: Color.grey.base)
    let copyButton = IconButton(image: UIImage(named: "baseline_file_copy_white_24pt"), tintColor: Color.grey.base)
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = RobotoFont.regular(with: 14)
        label.textColor = Color.grey.darken1
        label.numberOfLines = 0
        return label
    }()
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = RobotoFont.regular(with: 14)
        label.textColor = Color.grey.base
        label.numberOfLines = 0
        return label
    }()
    
    let noticeLabel: UILabel = {
        let label = UILabel()
        label.font = RobotoFont.regular(with: 12)
        label.textColor = Color.grey.base
        label.numberOfLines = 0
        return label
    }()
    let contentImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.red
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let card:UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()
    
    var copyHandler: (() -> Void)?
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.font = RobotoFont.regular(with: 14)
        return label
    }()
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, model:PreviewModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = Color.grey.lighten3
        
        contentView.addSubview(card)
        card.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
        
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(bodyLabel)
        
        card.addSubview(titleStackView)

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
        }
        bodyLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
        }
        
        titleStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(copyButton)
            make.left.equalToSuperview()
            make.right.equalTo(copyButton.snp.left)
        }
        
        card.addSubview(copyButton)
        card.addSubview(previewButton)
    
        previewButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(card.snp.top).offset(40)
            make.width.height.equalTo(40)
        }
        copyButton.snp.makeConstraints { (make) in
            make.right.equalTo(previewButton.snp.left).offset(-10)
            make.centerY.equalTo(previewButton)
            make.width.height.equalTo(40)
        }
        
        let contentStackView = UIStackView()
        
        
        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(contentImageView)
        contentStackView.addArrangedSubview(noticeLabel)
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        contentImageView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        noticeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        

    
        self.bind(model: model)

        
        previewButton.addTarget(self, action: #selector(preview), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyURL), for: .touchUpInside)
        noticeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noticeTap)))
        
    }
    @objc func noticeTap(){
//        if let controller = self.previewModel?.moreViewController{
//            Client.shared.currentNavigationController?.pushViewController(controller, animated: true)
//        }
    }
    @objc func copyURL(){
        if let urlStr = self.contentLabel.text{
            UIPasteboard.general.string = urlStr
            copyHandler?()
        }
    }
    @objc func preview(){
        
        if let urlStr = self.contentLabel.text?.urlEncoded(),
            let url = URL(string: urlStr){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var previewModel:PreviewModel?
    func bind(model:PreviewModel) {
        self.previewModel = model
        
        var fontSize:CGFloat = 14
        if UIScreen.main.bounds.size.width <= 320 {
            fontSize = 11
        }
        
        let serverUrl = URL(string: ServerManager.shared.currentAddress)!
        
        let attrStr = NSMutableAttributedString(string: "")
        attrStr.append(NSAttributedString(string: serverUrl.absoluteString, attributes: [
            NSAttributedString.Key.foregroundColor: Color.grey.darken4,
            NSAttributedString.Key.font : RobotoFont.regular(with: fontSize)
            ]))
        
        attrStr.append(NSAttributedString(string: "/\(Client.shared.key ?? "Your Key")", attributes: [
            NSAttributedString.Key.foregroundColor: Color.grey.darken3,
            NSAttributedString.Key.font : RobotoFont.regular(with: fontSize)
            ]))
        
        if let title = model.title {
            attrStr.append(NSAttributedString(string: "/\(title)", attributes: [
                NSAttributedString.Key.foregroundColor: Color.grey.darken1,
                NSAttributedString.Key.font : RobotoFont.regular(with: fontSize)
                ]))
            self.titleLabel.text = title
        }
        if let body = model.body {
            attrStr.append(NSAttributedString(string: "/\(body)", attributes: [
                NSAttributedString.Key.foregroundColor: Color.grey.base,
                NSAttributedString.Key.font : RobotoFont.regular(with: fontSize)
                ]))
            if model.title == nil {
                self.titleLabel.text = body
            }
            else{
                self.bodyLabel.text = body
            }
        }
        if self.bodyLabel.text?.count ?? 0 <= 0 {
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.centerY.equalTo(copyButton)
            }
        }
        else{
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(20)
            }
        }
        if let queryParameter = model.queryParameter {
            attrStr.append(NSAttributedString(string: "?\(queryParameter)", attributes: [
                NSAttributedString.Key.foregroundColor: Color.grey.lighten1,
                NSAttributedString.Key.font : RobotoFont.regular(with: fontSize)
                ]))
        }
        self.contentLabel.attributedText = attrStr
        
        if let moreInfo = model.moreInfo {
            let noticeStr = "\(model.notice ?? "")  \(moreInfo)"
            let noticeAttrStr = NSMutableAttributedString(string: noticeStr, attributes: [
                NSAttributedString.Key.foregroundColor: Color.grey.base,
                NSAttributedString.Key.font : RobotoFont.regular(with: 12)
            ])
            noticeAttrStr.setAttributes([
                NSAttributedString.Key.foregroundColor: Color.blue.base,
                NSAttributedString.Key.font : RobotoFont.regular(with: 12)
            ], range: NSRange(location: noticeStr.count - moreInfo.count, length: moreInfo.count))
            self.noticeLabel.text = nil
            self.noticeLabel.attributedText = noticeAttrStr
            self.noticeLabel.isUserInteractionEnabled = true
        }
        else{
            self.noticeLabel.isUserInteractionEnabled = false
            self.noticeLabel.attributedText = nil
            self.noticeLabel.text = model.notice
        }

        if let image = model.image {
            self.contentImageView.image = image
            let width = UIScreen.main.bounds.size.width - 20
            let height = width / image.width  * image.height
            
            contentImageView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(previewButton.snp.bottom).offset(15)
                make.height.equalTo(height)
            }
            contentLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.top.equalTo(contentImageView.snp.bottom).offset(15)
            }
        }
        else{
            contentLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.top.equalTo(previewButton.snp.bottom).offset(20)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
