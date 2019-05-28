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
        kv.delegate = self
        kv.heightAnchor.constraint(equalToConstant: kLineViewHeight).isActive = true
        return kv
    }()
    
    
    public lazy var techLineView: TechLineView = {
        let tv = TechLineView()
        tv.delegate = self
        return tv
    }()
    
    
    fileprivate var candles: [CandleItems] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        fetchData()
        kLineView.candles = candles
        techLineView.candles = candles
        kLineView.chartsScrollView.delegate = self
        techLineView.chartsScrollView.delegate = self
        
    }
    
    fileprivate func setupLayout(){
        
        let overallStackView = UIStackView()
        overallStackView.axis = .vertical
        overallStackView.addArrangedSubview(kLineView)
        overallStackView.addArrangedSubview(techLineView)
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


extension ChartViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        kLineView.caculateScrollViewDidScroll(scrollView: scrollView)
        techLineView.caculateScrollViewDidScroll(scrollView: scrollView)
        switch scrollView {
        case kLineView.chartsScrollView :
            techLineView.chartsScrollView.contentOffset = scrollView.contentOffset
        case techLineView.chartsScrollView :
            kLineView.chartsScrollView.contentOffset = scrollView.contentOffset
        default:
            return
        }
    }
}

extension ChartViewController: AdjustWidthDelegate{
    func adjustTechLine(candleWidth: Double) {
        
        techLineView.candleWidth = candleWidth
    }
    
    func adjustKLine(candleWidth: Double) {
        
        kLineView.candleWidth = candleWidth
    }
    
}

