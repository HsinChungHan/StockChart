//
//  BasicStockView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class BasicStockView: UIView {

    let chartWidth = UIScreen.main.bounds.width * 2 / 3
    let labelHeight: CGFloat = 40
    
    fileprivate let topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        return view
    }()
    
    fileprivate lazy var leftView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    fileprivate lazy var rightView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    fileprivate let bottomView: UIView = {
        let view = UILabel()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
    
    
    fileprivate lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        return view
    }()
    
    
    fileprivate lazy var chartsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.widthAnchor.constraint(equalToConstant: chartWidth).isActive = true
        return sv
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    
    
    fileprivate func setupLayout(){
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        [leftView, chartsScrollView, rightView].forEach({stackView.addArrangedSubview($0)})
        addSubview(topView)
        addSubview(stackView)
        addSubview(bottomView)
        topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        topView.anchor(top: topAnchor, bottom: nil, leading: nil, trailing: nil, padding: .zero, size: .init(width: chartWidth, height: labelHeight))
        
        bottomView.anchor(top: nil, bottom: bottomAnchor, leading: topView.leadingAnchor, trailing: topView.trailingAnchor, padding: .zero, size: .init(width: 0, height: labelHeight))
        
        stackView.anchor(top: topView.bottomAnchor, bottom: bottomView.topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        chartsScrollView.addSubview(contentView)
        contentView.fillSuperView()
        contentView.heightAnchor.constraint(equalToConstant: frame.height - (labelHeight*2)).isActive = true
        contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: chartWidth).isActive = true
        
        
    }

}
