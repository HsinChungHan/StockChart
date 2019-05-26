//
//  KlineContentView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/25.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class KlineContentView: UIView {
    var chartManager = ChartManager()
    var visibleCount: Int{
        didSet{
            drawChartContentView()
            drawKTech(values: MAValues)
            setNeedsDisplay()
        }
    }
    
    var candleWidth: Double{
        didSet{
//            drawChartContentView()
//            drawKTech(values: MAValues)
            setNeedsDisplay()
        }
    }
    fileprivate var MAValues: [KTech: [Double]] = [:]{
        didSet{
            group.notify(queue: DispatchQueue.main){
                self.setNeedsDisplay()
            }
        }
    }
    var candles: [CandleItems]
    
    var startCandle: Int = 0{
        didSet{
//            drawChartContentView()
            setNeedsDisplay()
        }
    }
    var kLineView: KLineView
    let group = DispatchGroup()
    init(candles: [CandleItems], candleWidth: Double, visibleCount: Int, kLineView: KLineView) {
        self.candles = candles
        self.candleWidth = candleWidth
        self.visibleCount = visibleCount
        self.kLineView = kLineView
        super.init(frame: .zero)
        
        DispatchQueue.global(qos: .userInteractive).async(group: group){
            self.MAValues = self.chartManager.computeMA(candles: self.candles)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        drawChartContentView()
//        drawKTech(values: MAValues)
//    }
    
    override func draw(_ rect: CGRect) {
//        super.draw(rect)
        drawChartContentView()
        drawKTech(values: MAValues)
    }
   
    
    //MARK: -Draw Chart
    fileprivate func drawACandle(high: Double, low: Double, open: Double, close: Double, sequence: Int){
        let candleValue: [CandleValue: CGFloat] = [
            .yHigh : kLineView.convertPosition(system: .Right, value: high),
            .yLow: kLineView.convertPosition(system: .Right, value: low),
            .yOpen: kLineView.convertPosition(system: .Right, value: open),
            .yClose: kLineView.convertPosition(system: .Right, value: close),
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
 
    //MARK: -Draw KTech Line
    
    fileprivate func drawKTech(values: [KTech: [Double]]){
        let keys = values.keys
        for key in keys{
            let techLine = UIBezierPath()
            let techLineLayer = CAShapeLayer()
            var strokeColor: CGColor{
                switch key {
                case .MA5 :
                    return #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1).cgColor
                case .MA10:
                    return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
                case .MA30:
                    return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor
                }
            }
            if let selected = values[key], !selected.isEmpty{
                
                let firstValue = kLineView.convertPosition(system: .Right, value: selected[0])
                techLine.move(to: CGPoint.init(x: CGFloat(candleWidth / 2), y: firstValue))
                for index in max(1, startCandle) ... min(candles.count - 1, startCandle + visibleCount){
                    let xPosition = CGFloat(Double(index)*candleWidth) + CGFloat(candleWidth/2)
                    let yPosition = kLineView.convertPosition(system: .Right, value: selected[index])
                    techLine.addLine(to: CGPoint.init(x: xPosition, y: yPosition))
                    print("xPosition: \(xPosition)")
                    print("yPosition: \(yPosition)")
                }
                
                techLineLayer.path = techLine.cgPath
                techLineLayer.lineWidth = 1.0
                techLineLayer.strokeColor = strokeColor
                techLineLayer.fillColor = UIColor.clear.cgColor
                layer.addSublayer(techLineLayer)
            }
        }
    }
    
}
