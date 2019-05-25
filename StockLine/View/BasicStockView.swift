//
//  BasicStockView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

enum PositionSystem{
    case Right
    case Left
}
class BasicStockView: UIView {
    var rightMax: Double = 0
    var rightMin: Double = 0
    var rightDiff: Double {
        return rightMax - rightMin
    }
    
    //MARK: -Const
    let chartWidth = UIScreen.main.bounds.width * 2 / 3
    let labelHeight: CGFloat = 40
    let candleWidth: Double = 5
    
    //MARK:- Properties
    var dottedLineLength = 5
    fileprivate var chartManager = ChartManager()
    fileprivate var MAValues: [String: [Double]] = [:]
    var candles: [CandleItems] = []{
        didSet{
            DispatchQueue.global(qos: .userInteractive).async {
                self.MAValues = self.chartManager.computeMA(candles: self.candles)
            }
        }
    }
    var visibleCount: Int{
        return Int(gridView.frame.width / CGFloat(candleWidth))
    }
    var horizontalLines = 4
    var verticalLines = 3
    
    //MARK: View
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        return view
    }()
    
    lazy var leftView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    lazy var gridView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: chartWidth).isActive = true
        return view
    }()
    
    
    lazy var chartsScrollView: UIScrollView = {
       let sv = UIScrollView()
        sv.backgroundColor = .clear
        sv.isScrollEnabled = true
        return sv
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    
    
    
    
    
    fileprivate func setupLayout(){
        addSubview(topView)
        addSubview(leftView)
        addSubview(gridView)

        topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        topView.anchor(top: topAnchor, bottom: nil, leading: nil, trailing: nil, padding: .zero, size: .init(width: chartWidth, height: labelHeight))
        topView.layoutIfNeeded()
        gridView.anchor(top: topView.bottomAnchor, bottom: nil, leading: nil, trailing: nil, padding: .zero, size: .init(width: chartWidth, height: frame.height - (topView.frame.height*2)))
        gridView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        leftView.anchor(top: gridView.topAnchor, bottom: gridView.bottomAnchor, leading: leadingAnchor, trailing: gridView.leadingAnchor, padding: .zero, size: .zero)
        
        gridView.addSubview(chartsScrollView)
        chartsScrollView.fillSuperView()
    }
    
    
    
    func drawDottedLines(horizontalLines: Int, verticalLines: Int){
        gridView.layoutIfNeeded()
        let gridBorder = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: gridView.frame.width, height: gridView.frame.height), cornerRadius: 0)
        print("gridView.frame.width: \(gridView.frame.width)")
        //draw border of gridView
        let gridBorderLayer = CAShapeLayer()
        gridBorderLayer.path = gridBorder.cgPath
        gridBorderLayer.lineWidth = 1
        gridBorderLayer.strokeColor = UIColor.black.cgColor
        gridBorderLayer.fillColor = UIColor.clear.cgColor
        gridView.layer.addSublayer(gridBorderLayer)
        
        //draw horizontal dotted lines
        for index in 1...horizontalLines - 1{
            let gridLine = UIBezierPath()
            let gridLineLayer = CAShapeLayer()
            let y = gridView.frame.height * CGFloat(Double(index) / Double(horizontalLines))
            gridLine.move(to: CGPoint.init(x: 0, y: y))
            for xOffset in stride(from: 0, to: Int(gridView.frame.width), by: dottedLineLength){
                if (xOffset / dottedLineLength) % 2 == 0{
                    gridLine.move(to: CGPoint.init(x: CGFloat(xOffset), y: y))
                }else{
                    gridLine.addLine(to: CGPoint.init(x: CGFloat(xOffset), y: y))
                }
            }
            gridLineLayer.path = gridLine.cgPath
            gridLineLayer.lineWidth = 1
            gridLineLayer.strokeColor = UIColor.lightGray.cgColor
            gridView.layer.addSublayer(gridLineLayer)
        }
        
        //draw vertical dotted lines
        for index in 1...verticalLines - 1{
            let gridLine = UIBezierPath()
            let gridLineLayer = CAShapeLayer()
            let x = gridView.frame.width * CGFloat(Double(index) / Double(verticalLines))
            gridLine.move(to: CGPoint.init(x: x, y: 0))
            for yOffset in stride(from: 0, to: Int(gridView.frame.height), by: dottedLineLength){
                if (yOffset / dottedLineLength) % 2 == 0{
                    gridLine.move(to: CGPoint.init(x: x, y: CGFloat(yOffset)))
                }else{
                    gridLine.addLine(to: CGPoint.init(x: x, y: CGFloat(yOffset)))
                }
            }
            gridLineLayer.path = gridLine.cgPath
            gridLineLayer.lineWidth = 1
            gridLineLayer.strokeColor = UIColor.lightGray.cgColor
            gridView.layer.addSublayer(gridLineLayer)
        }
    }
    
}



