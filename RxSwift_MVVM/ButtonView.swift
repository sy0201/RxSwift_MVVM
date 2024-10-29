//
//  ButtonView.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/26/24.
//

import UIKit

class ButtonView: UIView {
    let tvButton: UIButton = {
       let button = UIButton()
        button.setTitle("TV", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.configuration = UIButton.Configuration.bordered()
        return button
    }()
    
    let movieButton: UIButton = {
       let button = UIButton()
        button.setTitle("Movie", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.configuration = UIButton.Configuration.bordered()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.addSubview(tvButton)
        self.addSubview(movieButton)
        
        tvButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        movieButton.snp.makeConstraints { make in
            make.leading.equalTo(tvButton.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
