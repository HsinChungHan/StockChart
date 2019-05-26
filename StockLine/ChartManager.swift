//
//  ChartManager.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation

enum KTech{
    case MA5
    case MA10
    case MA30
}

class ChartManager {
    func computeMA(candles: [CandleItems]) -> [KTech: [Double]]{
        var ma5: [Double] = []
        var ma10: [Double] = []
        var ma30: [Double] = []
        
        for (index, candle) in candles.enumerated(){
            var ma5Sum: Double = 0
            
            for j in (index - 4) ... index{
                //取得最高收盤價格
                let v5 = Double(candles[max(0, j)].Close) ?? 0
                ma5Sum += v5
            }
            
            var ma10Sum: Double = 0
            for j in (index - 9)...index {
                let v10: Double = Double(candles[max(0, j)].Close) ?? 0
                ma10Sum += v10
            }
            
            var ma30Sum: Double = 0
            for j in (index - 29)...index {
                let v30: Double = Double(candles[max(0, j)].Close) ?? 0
                ma30Sum += v30
            }
            ma5.append(ma5Sum / 5)
            ma10.append(ma10Sum / 10)
            ma30.append(ma30Sum / 30)
        }
        return [.MA5: ma5, .MA10: ma10, .MA30: ma30]
    }
}
