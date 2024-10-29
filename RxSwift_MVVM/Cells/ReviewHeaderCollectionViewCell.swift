//
//  ReviewHeaderCollectionViewCell.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 10/18/24.
//

import UIKit

class ReviewHeaderCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewHeaderCollectionViewCell"
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .regular)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, url: String) {
        if url.isEmpty {
            imageView.image = UIImage(systemName: "person.fill")
        } else {
            imageView.kf.setImage(with: URL(string: url))

        }
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
