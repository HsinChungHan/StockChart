//
//  Double_Extension.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
extension Double {
    /// Rounds the double to decimal places value
    fileprivate func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func translate(decimalPlaces: UInt8 = 5) -> String{
        return String(format: "%.\(decimalPlaces)f", roundTo(places: Int(decimalPlaces)))
    }
}
