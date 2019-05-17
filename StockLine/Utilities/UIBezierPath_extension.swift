//
//  UIBezierPath_extension.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/7.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
extension UIBezierPath{
    func createRectangle(originalPoint: CGPoint, width: CGFloat, height: CGFloat, fillColor: UIColor, strokeColor: UIColor){
        move(to: originalPoint)
        addLine(to: CGPoint(x: originalPoint.x + width, y: originalPoint.y))
        addLine(to: CGPoint(x: originalPoint.x + width, y: originalPoint.y + height))
        addLine(to: CGPoint(x: originalPoint.x, y: originalPoint.y + height))
        close()
        fillColor.setFill()
        strokeColor.setStroke()
        fill()
        stroke()
//        move(to: CGPoint.init(x: 0, y: 0 ))
//        addLine(to: CGPoint.init(x: 200, y: 30))
//        addLine(to: CGPoint.init(x: 80, y: 77))
//        close()
//        UIColor.orange.setFill()
//        #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).setStroke()
//        fill()
//        stroke()
    }
}
