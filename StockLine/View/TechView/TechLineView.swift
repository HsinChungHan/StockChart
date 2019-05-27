//
//  TechView.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/15.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

final class TechLineView: BasicStockView {
     var delegate: AdjustWidthDelegate?
    
    fileprivate var _horizontalLines: Int = 3
    override var horizontalLines: Int{
        get {return _horizontalLines}
        set {_horizontalLines = newValue}
    }
    
    fileprivate var _verticalLines: Int = 3
    override var verticalLines: Int{
        get {return _verticalLines}
        set {_verticalLines = newValue}
    }
    
    
    
    var scrollViewContentOffset: CGFloat = 0
    var visibleCount: Int{
        return Int(gridView.frame.width / CGFloat(candleWidth))
    }
    
    var candleWidth: Double = 5{
        didSet{
            rightView.visibleCount = visibleCount
            bottomView.visibleCount = visibleCount
            
            chartView.visibleCount = visibleCount
            chartView.candleWidth = candleWidth
            
            
            chartsScrollView.contentSize = CGSize.init(width: CGFloat(Double(candles.count) * candleWidth), height: gridView.frame.height)
            
            chartView.removeConstraint(chartView.constraints[1])
            chartView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
            
            
            //要記得縮放時需讓scrollView跟這移動到當前start candle的位置
            //因為在KLineContentView中所計算的start candle xPosition，會因為candle width的改變
            //而往後排列，無法緊貼在畫面最左邊，造成放大時畫面左邊會一片空白
            let x = candleWidth / 2 + Double(startCandle) * candleWidth
            chartsScrollView.contentOffset = CGPoint(x: x, y: 0)
            
        }
    }
    
    
    fileprivate var theCurrentPrice: Double {
        let value = Double(candles.last?.Close ?? "0") ?? 0
        currentLineView.currentPrice = value
        return value
    }
    
    fileprivate var startCandle = 0{
        didSet{
            rightView.startCandle = startCandle
            bottomView.startCandle = startCandle
            chartView.startCandle = startCandle
        }
    }
    
    lazy var rightView: TechLineRightView = {
        let view = TechLineRightView.init(visibleCount: visibleCount, horizontalLines: horizontalLines)
        view.candles = candles
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    lazy var bottomView: TechLineBottomView = {
        let view = TechLineBottomView.init(candles: candles, visibleCount: visibleCount, verticalLines: verticalLines)
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
    lazy var chartView: TechLineContentView = {
        let view = TechLineContentView.init(candleWidth: candleWidth, visibleCount: visibleCount, techLineView: self)
        view.candles = candles
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch(sender:)))
        view.addGestureRecognizer(pinch)
        view.backgroundColor = .clear
        return view
    }()
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer){
        let offset: Double = (sender.scale > 1) ? 0.5 : -0.5
        candleWidth = max(2, min(30, candleWidth + offset))
        print("visibleCount: \(visibleCount)")
        print("HHHH")
        delegate?.adjustKLine(candleWidth: candleWidth)
        
    }
    
    lazy var currentLineView: CurrentLineView = {
        let cv = CurrentLineView()
        return cv
    }()
    
   
    
    fileprivate func setupLayout() {
        addSubview(rightView)
        rightView.anchor(top: gridView.topAnchor, bottom: gridView.bottomAnchor, leading: gridView.trailingAnchor, trailing: trailingAnchor)
        
        
        chartsScrollView.addSubview(chartView)
        chartView.anchor(top: chartsScrollView.topAnchor, bottom: chartsScrollView.bottomAnchor, leading: chartsScrollView.leadingAnchor, trailing: nil)
        chartView.heightAnchor.constraint(equalToConstant: frame.height - (topView.frame.height*2)).isActive = true
        
        
        chartView.widthAnchor.constraint(equalToConstant: CGFloat(Double(candles.count) * candleWidth)).isActive = true
        chartView.layoutIfNeeded()
        print("chartView.frame.width: \(chartView.frame.width)")
        
        //一定要在設定chartsScrollView.contentSize之前，執行layoutIfNeeded()
        //因為有可能chartsScrollView.width = 0，導致chartsScrollView.contentSize的設定的width皆為0
        chartsScrollView.layoutIfNeeded()
        chartsScrollView.contentSize = CGSize.init(width: CGFloat(Double(candles.count) * candleWidth), height: gridView.frame.height)
        
        addSubview(bottomView)
        bottomView.anchor(top: gridView.bottomAnchor, bottom: bottomAnchor, leading: nil, trailing: nil)
        bottomView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalToConstant: chartWidth).isActive = true
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        super.drawDottedLines(horizontalLines: horizontalLines, verticalLines: verticalLines)
        setupLayout()
    }
    
    
    
    
    public func convertPosition(system: PositionSystem, value: Double ) -> CGFloat{
        rightView.layoutIfNeeded()
        switch system{
        case .Right:
            return CGFloat((rightView.rightMax - value) / rightView.rightDiff) * rightView.frame.height
        default:
            return 0
        }
    }
    
    public func caculateScrollViewDidScroll(scrollView: UIScrollView){
        if Int(Double(scrollView.contentOffset.x) / candleWidth) < 0{
            startCandle = 0
        }else if Int(Double(scrollView.contentOffset.x) / candleWidth) > candles.count - 1{
            startCandle = (candles.count) - visibleCount
        }else{
            startCandle = Int(Double(scrollView.contentOffset.x) / candleWidth)
        }
    }
    
}

