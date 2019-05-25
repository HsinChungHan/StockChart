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
    var isMountain = false
    
    fileprivate var theCurrentPrice: Double {
        let value = Double(candles.last?.Close ?? "0") ?? 0
        return value
    }
    
    fileprivate var startCandle = 0
   
    lazy var rightView: KLineRightView = {
        let view = KLineRightView.init(candles: candles, visibleCount: visibleCount, horizontalLines: horizontalLines)
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    lazy var bottomView: KLineBottomView = {
        let view = KLineBottomView.init(candles: candles, visibleCount: visibleCount, verticalLines: verticalLines)
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
    
    
    
    fileprivate func setupLayout() {
        addSubview(rightView)
        rightView.anchor(top: gridView.topAnchor, bottom: gridView.bottomAnchor, leading: gridView.trailingAnchor, trailing: trailingAnchor)
        print("gridView: \(gridView.frame.height)")
        chartsScrollView.contentSize = CGSize.init(width: CGFloat(Double(candles.count) * candleWidth), height: gridView.frame.height)
        chartView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
        
        
        addSubview(bottomView)
        bottomView.anchor(top: gridView.bottomAnchor, bottom: bottomAnchor, leading: nil, trailing: nil)
        bottomView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalToConstant: chartWidth).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        super.drawDottedLines(horizontalLines: horizontalLines, verticalLines: verticalLines)
        
        setupLayout()
        
        drawChartContentView()
        chartsScrollView.delegate = self
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
        chartView.layer.addSublayer(highLowLayer)
        
        let openCloseLine = UIBezierPath()
        let openCloseLayer = CAShapeLayer()
        openCloseLine.move(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yOpen]!))
        openCloseLine.addLine(to: CGPoint.init(x: candleValue[.xPosition]!, y: candleValue[.yClose]!))
        openCloseLayer.path = openCloseLine.cgPath
        openCloseLayer.lineWidth = CGFloat(candleWidth)
        openCloseLayer.strokeColor = strokeColor
        chartView.layer.addSublayer(openCloseLayer)
    }
    
    fileprivate func drawChartContentView(){
        let firstVisibleCandle = max(0, startCandle)
        let lastVisibleCandle = min(candles.count-1, startCandle+visibleCount)
        chartView.layer.sublayers = []
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
        startCandle = Int(Double(scrollView.contentOffset.x) / candleWidth) > 0 ? Int(Double(scrollView.contentOffset.x) / candleWidth) : 0
        rightView.startCandle = startCandle
        bottomView.startCandle = startCandle
        drawChartContentView()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("You drag me")
    }
    
    
}
