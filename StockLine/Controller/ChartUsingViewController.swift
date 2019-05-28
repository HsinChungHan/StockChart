//
//  ChartUsingViewController.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

enum Strategy: String, CaseIterable{
    case today = "Time"
    case candle = "Candle"
    case ma = "MA"
    case boll = "BOLL"
    case arbr = "ARBR"
    case macd = "MACD"
    
}

final class ChartUsingViewController: UIViewController {
    let buttonStackView = UIStackView()
    let contentView = UIView()
    let chartVC = ChartViewController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLayout()
        embadedVCInContentView()
    }
    
    fileprivate func setupLayout(){
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        Strategy.allCases.forEach { (strategy) in
            let button = UIButton.init(type: .system)
            button.setTitle(strategy.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.addTarget(self, action: #selector(changeStrategy(sender:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        let overallStackView = UIStackView()
        overallStackView.axis = .vertical
        overallStackView.addArrangedSubview(buttonStackView)
        overallStackView.addArrangedSubview(contentView)
        view.addSubview(overallStackView)
        overallStackView.fillSuperView()
        
        buttonStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        contentView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    }
    
    @objc func changeStrategy(sender: UIButton){
        switch sender.title(for: .normal) {
        case Strategy.today.rawValue :
            chartVC.kLineView.chartView.techType = .candle
        case Strategy.candle.rawValue:
            chartVC.kLineView.chartView.techType = .candle
        case Strategy.ma.rawValue:
            chartVC.kLineView.chartView.techType = .ma
        case Strategy.boll.rawValue:
            chartVC.kLineView.chartView.techType = .boll
        case Strategy.macd.rawValue:
            chartVC.techLineView.rightView.techType = .macd
            chartVC.techLineView.chartView.techType = .macd
        case Strategy.arbr.rawValue:
            chartVC.techLineView.rightView.techType = .arbr
            chartVC.techLineView.chartView.techType = .arbr
        default:
            return
        }
    }
    
    fileprivate func embadedVCInContentView() {
        addChild(chartVC)
        contentView.addSubview(chartVC.view)
        chartVC.view.fillSuperView()
        chartVC.didMove(toParent: self)
    }
}
