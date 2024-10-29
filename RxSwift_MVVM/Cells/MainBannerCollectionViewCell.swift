//
//  MainBannerCollectionViewCell.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 10/7/24.
//

import UIKit

class MainBannerCollectionViewCell: UICollectionViewCell {
    static let id = "MainBannerCollectionViewCell"
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        return titleLabel
    }()
    
    let reviewLabel: UILabel = {
        let reviewLabel = UILabel()
        reviewLabel.font = .systemFont(ofSize: 14, weight: .light)
        return reviewLabel
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .light)
        descriptionLabel.numberOfLines = 3
        return descriptionLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(reviewLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(500)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.bottom.equalToSuperview().offset(-14)
        }
    }
    
    func configure(title: String, overView: String, review: String, url: String) {
        imageView.kf.setImage(with: URL(string: url))
        titleLabel.text = title
        reviewLabel.text = review
        descriptionLabel.text = overView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
