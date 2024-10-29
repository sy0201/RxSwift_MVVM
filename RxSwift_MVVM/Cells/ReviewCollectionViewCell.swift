//
//  ReviewCollectionViewCell.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 10/18/24.
//

import UIKit

class ReviewCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewCollectionViewCell"
    
    let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.font = .systemFont(ofSize: 20, weight: .regular)
        return contentLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentLabel)

        contentLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(14)
        }
    }
    
    func configure(content: String) {
        contentLabel.text = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
