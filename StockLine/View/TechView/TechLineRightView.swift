//
//  TechLineRightView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/26.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class TechLineRightView: UIView {

    var horizontalLines: Int
    let decimalPlaces: UInt8 = 3
    fileprivate var chartManager = ChartManager()
    var startCandle = 0{
        didSet{
            fetchAndRedrawRightView()
        }
    }
//    fileprivate var MAValues: [KTech: [Double]] = [:]
    fileprivate var ARBRValues: [Tech: [Double]] = [:]
    var candles: [CandleItems] = []{
        didSet{
            DispatchQueue.global(qos: .userInteractive).async {
                self.ARBRValues = self.chartManager.computeARBR(candles: self.candles)
                DispatchQueue.main.async {
                    self.fetchRightMaxAndMin(values: self.ARBRValues)
                    self.setupRightView()
                }
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
            fetchRightMaxAndMin(values: ARBRValues)
            setupRightView()
        }
    }
    init(visibleCount: Int, horizontalLines: Int) {
        self.visibleCount = visibleCount
        self.horizontalLines = horizontalLines
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        fetchAndRedrawRightView()
    }
    
    //MARK: - Right View
    //MARK: - todo 數值有問題
    fileprivate func fetchRightMaxAndMin(values: [Tech: [Double]]){
        //因為像AR、BR共有兩個Key
        //所以需要找尋在可視範圍中，兩個Key的最大值
        var theMaxs = [Double]()
        var theMins = [Double]()
        let keys = values.keys
        for key in keys{
            let items: [Double] = values[key] ?? []
            var itemMax: Double = 0
            var itemMin: Double = 0
            var itemDiff: Double{
                return itemMax - itemMin
            }
            
            var visibleItems = ArraySlice<Double>()
            //第一跟蠟燭和最後一根蠟燭必定會貼齊最左和最右
            if startCandle + visibleCount < candles.count{
                visibleItems = items[max(0, startCandle)...(startCandle+visibleCount)]
            }else{
                //一定會是最後一組candles
                visibleItems = items[startCandle...(candles.count - 1)]
            }
            itemMax = visibleItems.max() ?? 0
            itemMin = visibleItems.min() ?? 0
            
            //顯示的最大值將會比真實的最大值大上一點點
            itemMax = itemMax + itemDiff * 0.1
            itemMin = itemMin - itemDiff * 0.1
            
            //最後再把rightMax和rightMin加進theMaxs和theMins
            //以便等等可以找出當下兩條線的最大和最小值
            theMaxs.append(itemMax)
            theMins.append(itemMin)
        }
        
        //如此可找到多條線的最大值和最小值
        rightMax = theMaxs.max() ?? 0
        rightMin = theMins.min() ?? 0
        print(rightMax)
        print(rightMin)
        print("-----------")
    }
    
    fileprivate func setupRightLabel(value: String, yPosition: Int, storedArray: inout [UILabel]){
        let valueLabel = UILabel.init(frame: CGRect.init(x: 0, y: yPosition - 8, width: Int(frame.width), height: 16))
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 10)
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
        fetchRightMaxAndMin(values: ARBRValues)
        setupRightView()
    }
}



