//
//  KLineRightView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/24.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

final class KLineRightView: UIView {
    var horizontalLines: Int
    let decimalPlaces: UInt8 = 5
    fileprivate var chartManager = ChartManager()
    var startCandle = 0{
        didSet{
            fetchAndRedrawRightView()
        }
    }
    fileprivate var MAValues: [String: [Double]] = [:]
    var candles: [CandleItems] = []{
        didSet{
            DispatchQueue.global(qos: .userInteractive).async {
                self.MAValues = self.chartManager.computeMA(candles: self.candles)
            }
        }
    }
    var currentRightLabels = [UILabel]()
    var rightMax: Double = 0
    var rightMin: Double = 0
    var rightDiff: Double {
        return rightMax - rightMin
    }
   
    var visibleCount: Int{
        didSet{
            fetchRightMaxAndMin()
            setupRightView()
        }
    }
    init(candles: [CandleItems], visibleCount: Int, horizontalLines: Int) {
        self.visibleCount = visibleCount
        self.horizontalLines = horizontalLines
        super.init(frame: .zero)
        self.candles = candles
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fetchAndRedrawRightView()
    }
    
    //MARK: - Right View
    fileprivate func fetchRightMaxAndMin(){
        var visibleCandles = ArraySlice<CandleItems>()
        //第一跟蠟燭和最後一根蠟燭必定會貼齊最左和最右
        if startCandle + visibleCount < candles.count{
            print("startCandle: \(startCandle)")
            visibleCandles = candles[max(0, startCandle)...(startCandle+visibleCount)]
        }else{
            //一定會是最後一組candles
            visibleCandles = candles[startCandle...(candles.count - 1)]
        }
        rightMax = Double(visibleCandles.map{$0.High}.max() ?? "0")  ?? 0
        rightMin = Double(visibleCandles.map{$0.Low}.min() ?? "0")  ?? 0
        
        //顯示的最大值將會比真實的最大值大上一點點
        rightMax = rightMax + rightDiff * 0.2
        rightMin = rightMin - rightDiff * 0.2
        
        print("rightMax: \(rightMax)")
        print("rightMin: \(rightMin)")
    }
    
    fileprivate func setupRightLabel(value: String, yPosition: Int, storedArray: inout [UILabel]){
        let valueLabel = UILabel.init(frame: CGRect.init(x: 0, y: yPosition - 8, width: Int(frame.width), height: 16))
        valueLabel.text = value
        addSubview(valueLabel)
        storedArray.append(valueLabel)
    }
    
    
    fileprivate func setupRightView(){
        //每一次滑動，都要先清除原有的labels
        currentRightLabels = []
        for label in subviews{
            label.removeFromSuperview()
        }
        
        layoutIfNeeded()
        setupRightLabel(value: rightMax.translate(decimalPlaces: decimalPlaces) , yPosition: 8, storedArray: &currentRightLabels)
        
        //這邊-1是希望將最下面的label另外設定位置
        for index in 1...horizontalLines - 1{
            let y = frame.height * CGFloat(Double(index) / Double(horizontalLines))
            setupRightLabel(value: (rightMax - rightDiff * Double(index) / Double(horizontalLines)).translate(decimalPlaces: decimalPlaces) , yPosition: Int(y), storedArray: &currentRightLabels)
        }
        setupRightLabel(value: rightMin.translate(decimalPlaces: decimalPlaces) , yPosition: Int(frame.height) - 8, storedArray: &currentRightLabels)
    }
    
    public func fetchAndRedrawRightView(){
        fetchRightMaxAndMin()
        setupRightView()
    }
    
    public func convertPosition(system: PositionSystem, value: Double ) -> CGFloat{
        layoutIfNeeded()
        switch system{
        case .Right:
            return CGFloat((rightMax - value) / rightDiff) * frame.height
        default:
            return 0
        }
    }
}
