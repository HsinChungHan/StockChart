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
    
    public lazy var kLineView: KLineView = {
        let kv = KLineView()
        kv.heightAnchor.constraint(equalToConstant: kLineViewHeight).isActive = true
        return kv
    }()
    
    
    fileprivate lazy var techView: TechView = {
        let tv = TechView()
        tv.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - kLineViewHeight).isActive = true
        return tv
    }()
    
    fileprivate let chartmanager = ChartManager()
    fileprivate var candleWidth: Double = 5{
        didSet{
            
        }
    }
    fileprivate var candles: [CandleItems] = []
    fileprivate var theCurrentPrice: Double = 0
    fileprivate var startCandle: Int = 0
    fileprivate var visibleCount: Int = 0
    
    fileprivate var dottedLineLength = 5
    
    fileprivate var decimalPlaces: UInt8 = 5
    fileprivate var tecDecimalPlaces: UInt = 2
    
    fileprivate var techUnit: String = ""
    
    fileprivate var horizontalLines = 0
    fileprivate var techHorizontalLines = 0
    fileprivate var verticalLines = 0
    
    fileprivate var currentRightLabels: [UILabel] = []
    fileprivate var currentBottomLabels: [UILabel] = []
    fileprivate var currentTechRightLabels: [UILabel] = []
    
    fileprivate var rightMax: Double = 0
    fileprivate var rightMin: Double = 0
    fileprivate var rightDiff: Double{
        return rightMax - rightMin
    }
    
    fileprivate var techRightMax: Double = 0
    fileprivate var techRightMin: Double = 0
    fileprivate var techRightDiff: Double{
        return rightMax - rightMin
    }
    
    var MAValues: [String: [Double]] = [:]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        fetchData()
        kLineView.candles = candles
    }
    
    fileprivate func setupLayout(){
        let overallStackView = UIStackView()
        overallStackView.axis = .vertical
        overallStackView.addArrangedSubview(kLineView)
        overallStackView.addArrangedSubview(techView)
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor , bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func fetchData(){
        guard let url = Bundle.main.url(forResource: "PreviousCandles", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                return
        }
        
        do {
            let json = try JSONDecoder().decode(CandlesModel.self, from: data)
            candles = json.candleItems
        } catch {
            print("candles decode fail")
        }
    }
}
