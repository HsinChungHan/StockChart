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
    
    fileprivate var MACDValue: [Tech: [Double]] = [:]{
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
                self.MACDValue = self.chartManager.computeMACD(candles: self.candles)
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
        drawTech(techType: techType)
    }
    
    //MARK: -Draw KTech Line
    fileprivate func drawTech(techType: Strategy){
        switch techType {
        case .arbr:
            implementTechLine(values: ARBRValue)
        case .macd:
            implementTechLine(values: MACDValue)
        default:
            return
        }
    }
    
    fileprivate func implementTechLine(values: [Tech: [Double]]){
        layer.sublayers = []
        let keys = values.keys
        for key in keys{
            if key == .OSC{//MACD的柱狀圖
                if let selected = values[.OSC], !selected.isEmpty {
                    for index in max(0, startCandle)...min(candles.count - 1, startCandle+visibleCount){
                        drawMACDBar(startValue: selected[index], sequence: index)
                    }
                }
            }else{
                drawCommonTechLine(key, values)
            }
            
        }
    }
    
    fileprivate func drawMACDBar(startValue: Double, sequence: Int){
        let x = CGFloat(Double(sequence) * candleWidth) + CGFloat(candleWidth/2)
        let yStart = techLineView.convertPosition(system: .Right, value: startValue)
        let yEnd = techLineView.convertPosition(system: .Right, value: 0)
        
        let strokeColor = (startValue > 0) ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor : #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor
        
        let barLine = UIBezierPath()
        let barLayer = CAShapeLayer()
        barLine.move(to: CGPoint.init(x: x, y: yStart))
        barLine.addLine(to: CGPoint.init(x: x, y: yEnd))
        barLayer.path = barLine.cgPath
        barLayer.lineWidth = CGFloat(candleWidth - 1)
        barLayer.strokeColor = strokeColor
        layer.addSublayer(barLayer)
        
    }
    
    fileprivate func drawCommonTechLine(_ key: Tech, _ values: [Tech : [Double]]) {
        let techLine = UIBezierPath()
        let techLineLayer = CAShapeLayer()
        var strokeColor: CGColor{
            switch key {
            case .AR:
                return #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1).cgColor
            case .BR:
                return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
            case .MACD:
                return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            case .DIF:
                return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
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
