//
//  KLineView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
enum ContentOffsetType {
    case Current
    case ToLast
}

enum CandleValue{
    case yHigh
    case yLow
    case yOpen
    case yClose
    case xPosition
}

final class KLineView: BasicStockView {
    fileprivate var chartManager = ChartManager()
    var horizontalLines = 4
    var verticalLines = 3
    var candleWidth: Double = 5
    
    var isMountain = false
    
    fileprivate var MAValues: [String: [Double]] = [:]
    var candles: [CandleItems] = []{
        didSet{
            DispatchQueue.global(qos: .userInteractive).async {
                self.MAValues = self.chartManager.computeMA(candles: self.candles)
            }
        }
    }
    fileprivate var theCurrentPrice: Double {
        let value = Double(candles.last?.Close ?? "0") ?? 0
        return value
    }
    
    fileprivate var startCandle = 0
    var visibleCount: Int{
        return Int(gridView.frame.width / CGFloat(candleWidth))
    }
    var dottedLength = 5
    let decimalPlaces: UInt8 = 5
    lazy var currentRightLabels = [UILabel]()
    lazy var currentBottomLabels = [UILabel]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        chartsScrollView.isScrollEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridView.layoutIfNeeded()
        super.drawDottedLines(horizontalLines: horizontalLines, verticalLines: verticalLines)
        chartsScrollView.contentSize = CGSize.init(width: CGFloat(Double(candles.count) * candleWidth), height: gridView.frame.height)
        
        
        chartContentView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
        
        fetchAndRedrawRightView()
        
        setupBottomView()
        
        drawChartContentView()
        chartsScrollView.delegate = self
    }
    
    func drawKLine(contentOffsetXType: ContentOffsetType = .ToLast) {
        
        chartsScrollView.isScrollEnabled = true
        //先移除之前的widthAnchor
        chartContentView.removeConstraint(chartContentView.constraints[1])
        chartContentView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
        
    }
    
    
    //MARK: - Right View
    fileprivate func fetchRightMaxAndMin(){
        var visibleCandles = ArraySlice<CandleItems>()
        //第一跟蠟燭和最後一根蠟燭必定會貼齊最左和最右
        if startCandle + visibleCount < candles.count{
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
        let valueLabel = UILabel.init(frame: CGRect.init(x: 0, y: yPosition - 8, width: Int(rightView.frame.width), height: 16))
        valueLabel.text = value
        rightView.addSubview(valueLabel)
        storedArray.append(valueLabel)
    }

    
    fileprivate func setupRightView(){
        //每一次滑動，都要先清除原有的labels
        currentRightLabels = []
        for label in rightView.subviews{
            label.removeFromSuperview()
        }
        
        
        rightView.layoutIfNeeded()
        setupRightLabel(value: rightMax.translate(decimalPlaces: decimalPlaces) , yPosition: 8, storedArray: &currentRightLabels)
        
        //這邊-1是希望將最下面的label另外設定位置
        for index in 1...horizontalLines - 1{
            let y = gridView.frame.height * CGFloat(Double(index) / Double(horizontalLines))
            setupRightLabel(value: (rightMax - rightDiff * Double(index) / Double(horizontalLines)).translate(decimalPlaces: decimalPlaces) , yPosition: Int(y), storedArray: &currentRightLabels)
        }
        setupRightLabel(value: rightMin.translate(decimalPlaces: decimalPlaces) , yPosition: Int(rightView.frame.height) - 8, storedArray: &currentRightLabels)
    }
    
    fileprivate func fetchAndRedrawRightView(){
        fetchRightMaxAndMin()
        setupRightView()
    }
    
    
    
    
    
    //MARK: - Bottom View
    fileprivate func setupBottomLabel(value: String, xPosition: Int, storedArray: inout [UILabel]){
        let dateLabel = UILabel.init(frame: CGRect.init(x: xPosition - 30, y: 0, width: 100, height: 16))
        dateLabel.numberOfLines = 0
        dateLabel.text = value
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.sizeToFit()
        dateLabel.textAlignment = .center
        bottomView.addSubview(dateLabel)
        storedArray.append(dateLabel)
    }

    
    
    fileprivate func setupBottomView(){
        //每一次滑動，都要先清除原有的labels
        currentBottomLabels = []
        for label in bottomView.subviews{
            label.removeFromSuperview()
        }
        
        
        setupBottomLabel(value: candles[max(0, startCandle)].Time.modifyTime() , xPosition: 0, storedArray: &currentBottomLabels)
        for index in 1...verticalLines{
            let x = gridView.frame.width * CGFloat(Double(index) / Double(verticalLines))
            let offset = Int(Double(visibleCount) * Double(index) / Double(verticalLines))
            print("Offset: \(offset)")
            setupBottomLabel(value: candles[max(0, min(candles.count - 1, startCandle + offset))].Time.modifyTime(), xPosition: Int(x), storedArray: &currentBottomLabels)
        }
    }
    
    
    //MARK: -Draw Chart
    fileprivate func drawACandle(high: Double, low: Double, open: Double, close: Double, sequence: Int){
        let candleValue: [CandleValue: CGFloat] = [
            .yHigh : convertPosition(system: .Right, value: high),
            .yLow: convertPosition(system: .Right, value: low),
            .yOpen: convertPosition(system: .Right, value: open),
            .yClose: convertPosition(system: .Right, value: close),
            .xPosition: CGFloat(Double(sequence) * candleWidth) + CGFloat(candleWidth/2)
        ]
        
        let strokeColor = (close > open) ? #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
        
        let highLowLine = UIBezierPath()
        let highLowLayer = CAShapeLayer()
        highLowLine.move(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yHigh]!))
        highLowLine.addLine(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yLow]!))
        highLowLayer.path = highLowLine.cgPath
        highLowLayer.lineWidth = 1
        highLowLayer.strokeColor = strokeColor
        chartContentView.layer.addSublayer(highLowLayer)
        
        let openCloseLine = UIBezierPath()
        let openCloseLayer = CAShapeLayer()
        openCloseLine.move(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yOpen]!))
        openCloseLine.addLine(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yClose]!))
        openCloseLayer.path = openCloseLine.cgPath
        openCloseLayer.lineWidth = CGFloat(candleWidth)
        openCloseLayer.strokeColor = strokeColor
        chartContentView.layer.addSublayer(openCloseLayer)
    }
    
    fileprivate func drawChartContentView(){
        let firstVisibleCandle = max(0, startCandle)
        let lastVisibleCandle = min(candles.count-1, startCandle+visibleCount)
        chartContentView.layer.sublayers = []
        for index in (firstVisibleCandle...lastVisibleCandle){
            let high = Double(candles[index].High) ?? 0
            let low = Double(candles[index].Low) ?? 0
            let open = Double(candles[index].Open) ?? 0
            let close = Double(candles[index].Close) ?? 0
            drawACandle(high: high, low: low, open: open, close: close, sequence: index)
        }
    }
}



extension KLineView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        startCandle = Int(Double(scrollView.contentOffset.x) / candleWidth)
        fetchAndRedrawRightView()
        setupBottomView()
        drawChartContentView()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("You drag me")
    }
    
    
}
