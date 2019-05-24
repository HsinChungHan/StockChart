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
    
    var dottedLength = 5
    lazy var currentBottomLabels = [UILabel]()
    
    
    lazy var rightView: KLineRightView = {
        let view = KLineRightView.init(candles: candles, visibleCount: visibleCount, horizontalLines: horizontalLines)
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    fileprivate func setWholeWidth() {
        chartsScrollView.contentSize = CGSize.init(width: CGFloat(Double(candles.count) * candleWidth), height: gridView.frame.height)
        chartContentView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridView.layoutIfNeeded()
        overallStackView.addArrangedSubview(rightView)
        super.drawDottedLines(horizontalLines: horizontalLines, verticalLines: verticalLines)
        setWholeWidth()
        
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
        rightView.startCandle = startCandle
        setupBottomView()
//        drawChartContentView()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("You drag me")
    }
    
    
}
