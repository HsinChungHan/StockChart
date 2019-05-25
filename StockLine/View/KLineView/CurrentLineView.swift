//
//  CurrentLineView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

final class CurrentLineView: UIView {
    public var currentPrice: Double = 0{
        didSet{
            currentPriceLabel.text = currentPrice.translate()
        }
    }
    
    
    fileprivate let currentLine: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return view
    }()
    
    let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout(){
        addSubview(currentLine)
        addSubview(currentPriceLabel)
        currentLine.anchor(top: nil, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor, padding: .zero, size: .init(width: 0, height: 3))
        currentLine.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        currentPriceLabel.anchor(top: topAnchor, bottom: bottomAnchor, leading: nil, trailing: trailingAnchor, padding: .zero, size: .init(width: UIScreen.main.bounds.width / 6, height: 0))
        
    }

}
