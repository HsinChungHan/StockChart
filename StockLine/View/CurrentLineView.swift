//
//  CurrentLineView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class CurrentLineView: UIView {

    fileprivate let currentLine: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return view
    }()
    
    fileprivate let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "20000"
        label.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout(){
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(currentLine)
        stackView.addArrangedSubview(currentPriceLabel)
        stackView.fillSuperView()
        
    }

}
