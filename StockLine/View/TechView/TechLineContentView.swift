//
//  TechLineContentView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/26.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class TechLineContentView: UIView {
    var chartManager = ChartManager()
    var visibleCount: Int{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var candleWidth: Double{
        didSet{
            setNeedsDisplay()
        }
    }
    
    fileprivate var ARBRValue: [Tech: [Double]] = [:]{
        didSet{
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    var candles: [CandleItems] = []{
        didSet{
            DispatchQueue.global(qos: .userInteractive).async {
                 self.ARBRValue = self.chartManager.computeARBR(candles: self.candles)
            }
           
        }
    }
    
    var startCandle: Int = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var techType: Strategy = .arbr{
        didSet{
            setNeedsDisplay()
        }
    }
    var techLineView: TechLineView
    init(candleWidth: Double, visibleCount: Int, techLineView: TechLineView) {
        self.candleWidth = candleWidth
        self.visibleCount = visibleCount
        self.techLineView = techLineView
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawKTech(techType: techType)
    }
    
    
    //MARK: -Draw Chart
    fileprivate func drawACandle(high: Double, low: Double, open: Double, close: Double, sequence: Int){
        let candleValue: [CandleValue: CGFloat] = [
            .yHigh : techLineView.convertPosition(system: .Right, value: high),
            .yLow: techLineView.convertPosition(system: .Right, value: low),
            .yOpen: techLineView.convertPosition(system: .Right, value: open),
            .yClose: techLineView.convertPosition(system: .Right, value: close),
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
    fileprivate func drawKTech(techType: Strategy){
        switch techType {
        case .arbr:
//            drawChartContentView()
            drawKTech(values: ARBRValue)
        default:
            return
        }
    }
    
    
    fileprivate func drawKTech(values: [Tech: [Double]]){
        layer.sublayers = []
        let keys = values.keys
        for key in keys{
            let techLine = UIBezierPath()
            let techLineLayer = CAShapeLayer()
            var strokeColor: CGColor{
                switch key {
                case .AR:
                    return #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1).cgColor
                case .BR:
                    return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
                default:
                    return UIColor.clear.cgColor
                }
            }
            if let selected = values[key], !selected.isEmpty{
                
                let firstValue = techLineView.convertPosition(system: .Right, value: selected[0])
                techLine.move(to: CGPoint.init(x: CGFloat(candleWidth / 2), y: firstValue))
                for index in max(1, startCandle) ... min(candles.count - 1, startCandle + visibleCount){
                    let xPosition = CGFloat(Double(index)*candleWidth) + CGFloat(candleWidth/2)
                    let yPosition = techLineView.convertPosition(system: .Right, value: selected[index])
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
