//
//  KLineBottomView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/25.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class KLineBottomView: UIView {
    lazy var currentBottomLabels = [UILabel]()
    var startCandle = 0{
        didSet{
            setupBottomView()
        }
    }
    var verticalLines = 4
    var visibleCount: Int{
        didSet{
             setupBottomView()
        }
    }
    fileprivate var MAValues: [String: [Double]] = [:]
    var candles: [CandleItems] = []{
        didSet{
//            DispatchQueue.global(qos: .userInteractive).async {
//                self.MAValues = self.chartManager.computeMA(candles: self.candles)
//            }
        }
    }
    init(candles: [CandleItems], visibleCount: Int, verticalLines: Int) {
        self.visibleCount = visibleCount
        super.init(frame: .zero)
        self.candles = candles
        self.verticalLines = verticalLines
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(frame.width)
        setupBottomView()
    }
    //MARK: - Bottom View
    fileprivate func setupBottomLabel(value: String, xPosition: Int, storedArray: inout [UILabel]){
        let dateLabel = UILabel.init(frame: CGRect.init(x: xPosition - 30, y: 0, width: 100, height: 16))
        dateLabel.numberOfLines = 0
        dateLabel.text = value
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.sizeToFit()
        dateLabel.textAlignment = .center
        addSubview(dateLabel)
        storedArray.append(dateLabel)
    }
    
    
    
    fileprivate func setupBottomView(){
        //每一次滑動，都要先清除原有的labels
        currentBottomLabels = []
        for label in subviews{
            label.removeFromSuperview()
        }
        
        setupBottomLabel(value: candles[max(0, startCandle)].Time.modifyTime() , xPosition: 0, storedArray: &currentBottomLabels)
        for index in 1...verticalLines{
            let x = frame.width * CGFloat(Double(index) / Double(verticalLines))
            let offset = Int(Double(visibleCount) * Double(index) / Double(verticalLines))
            print("Offset: \(offset)")
            setupBottomLabel(value: candles[max(0, min(candles.count - 1, startCandle + offset))].Time.modifyTime(), xPosition: Int(x), storedArray: &currentBottomLabels)
        }
    }
}
