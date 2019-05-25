//
//  KlineContentView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/25.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class KlineContentView: UIView {
    var candleWidth: Double
    var candles: [CandleItems]
    var visibleCount: Int
    var startCandle: Int = 0{
        didSet{
            drawChartContentView()
        }
    }
    var rightView: KLineRightView
    
    init(candles: [CandleItems], candleWidth: Double, visibleCount: Int, rightView: KLineRightView) {
        self.candles = candles
        self.candleWidth = candleWidth
        self.visibleCount = visibleCount
        self.rightView = rightView
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        drawChartContentView()
    }
    //MARK: -Draw Chart
    fileprivate func drawACandle(high: Double, low: Double, open: Double, close: Double, sequence: Int){
        let candleValue: [CandleValue: CGFloat] = [
            .yHigh : rightView.convertPosition(system: .Right, value: high),
            .yLow: rightView.convertPosition(system: .Right, value: low),
            .yOpen: rightView.convertPosition(system: .Right, value: open),
            .yClose: rightView.convertPosition(system: .Right, value: close),
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
        layer.addSublayer(highLowLayer)
        
        let openCloseLine = UIBezierPath()
        let openCloseLayer = CAShapeLayer()
        openCloseLine.move(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yOpen]!))
        openCloseLine.addLine(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yClose]!))
        openCloseLayer.path = openCloseLine.cgPath
        openCloseLayer.lineWidth = CGFloat(candleWidth)
        openCloseLayer.strokeColor = strokeColor
        layer.addSublayer(openCloseLayer)
    }
    
    fileprivate func drawChartContentView(){
        let firstVisibleCandle = max(0, startCandle)
        let lastVisibleCandle = min(candles.count-1, startCandle+visibleCount)
        layer.sublayers = []
        for index in (firstVisibleCandle...lastVisibleCandle){
            let high = Double(candles[index].High) ?? 0
            let low = Double(candles[index].Low) ?? 0
            let open = Double(candles[index].Open) ?? 0
            let close = Double(candles[index].Close) ?? 0
            drawACandle(high: high, low: low, open: open, close: close, sequence: index)
        }
    }
}
