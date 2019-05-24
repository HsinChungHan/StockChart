//
//  ChartViewController.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
final class ChartViewController: UIViewController {
    let kLineViewHeight = UIScreen.main.bounds.height * 2 / 3
    
    public lazy var kLineView: KLineView = {
        let kv = KLineView()
        kv.heightAnchor.constraint(equalToConstant: kLineViewHeight).isActive = true
        return kv
    }()
    
    
    fileprivate lazy var techView: TechView = {
        let tv = TechView()
        return tv
    }()
    
    
    fileprivate var candles: [CandleItems] = []
    
    
    
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
