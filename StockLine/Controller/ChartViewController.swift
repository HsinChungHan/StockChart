//
//  ChartViewController.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
class ChartViewController: UIViewController {
    let kLineViewHeight = UIScreen.main.bounds.height * 2 / 3
    
    fileprivate lazy var kLineView: KLineView = {
        let kv = KLineView()
        kv.heightAnchor.constraint(equalToConstant: kLineViewHeight).isActive = true
        return kv
    }()
    
    
    fileprivate lazy var techView: TechView = {
        let tv = TechView()
        tv.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - kLineViewHeight).isActive = true
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
    }
    
    fileprivate func setupLayout(){
        let overallStackView = UIStackView()
        overallStackView.axis = .vertical
        overallStackView.addArrangedSubview(kLineView)
        overallStackView.addArrangedSubview(techView)
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor , bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
    }
}
