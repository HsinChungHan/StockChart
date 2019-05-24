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
    
    //MARK:- Properties
    var dottedLineLength = 5
    
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
    
    lazy var rightView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - chartWidth)/2).isActive = true
        return view
    }()
    
    let bottomView: UIView = {
        let view = UILabel()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
    lazy var gridView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        //        view.widthAnchor.constraint(equalToConstant: chartWidth).isActive = true
        return view
    }()
    
    var chartContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    lazy var chartsScrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
        
    }
    
    
    
    
    
    
    fileprivate func setupLayout(){
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        [leftView, gridView, rightView].forEach({stackView.addArrangedSubview($0)})
        addSubview(topView)
        addSubview(stackView)
        addSubview(bottomView)
        topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        topView.anchor(top: topAnchor, bottom: nil, leading: nil, trailing: nil, padding: .zero, size: .init(width: chartWidth, height: labelHeight))
        
        bottomView.anchor(top: nil, bottom: bottomAnchor, leading: topView.leadingAnchor, trailing: topView.trailingAnchor, padding: .zero, size: .init(width: 0, height: labelHeight))
        
        stackView.anchor(top: topView.bottomAnchor, bottom: bottomView.topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        gridView.addSubview(chartsScrollView)
        chartsScrollView.fillSuperView()
        chartsScrollView.addSubview(chartContentView)
        chartContentView.anchor(top: chartsScrollView.topAnchor, bottom: chartsScrollView.bottomAnchor, leading: chartsScrollView.leadingAnchor, trailing: nil)
        chartContentView.heightAnchor.constraint(equalToConstant: frame.height - (labelHeight*2)).isActive = true
        chartContentView.widthAnchor.constraint(greaterThanOrEqualToConstant: chartWidth).isActive = true
    }
    
    
    func drawDottedLines(horizontalLines: Int, verticalLines: Int){
        gridView.layoutIfNeeded()
        let gridBorder = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: gridView.frame.width, height: gridView.frame.height), cornerRadius: 0)
        
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
    
    func convertPosition(system: PositionSystem, value: Double ) -> CGFloat{
        chartContentView.layoutIfNeeded()
        switch system{
        case .Right:
            return CGFloat((rightMax - value) / rightDiff) * chartContentView.frame.height
        default:
            return 0
        }
        
    }
    
}
