//
//  ChartManager.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation



enum Tech{
    case MA5
    case MA10
    case MA30
    case UP
    case MB
    case DN
    case AR
    case BR
}

class ChartManager {
    
    //MARK: -MA：均線
    func computeMA(candles: [CandleItems]) -> [Tech: [Double]]{
        var ma5: [Double] = []
        var ma10: [Double] = []
        var ma30: [Double] = []
        
        for (index, _) in candles.enumerated(){
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
    
    //MARK: -BOLL布林通道
    //mb:Ｎ日的移動平均線
    //up:middle+兩倍標準差
    //dn:middle-兩倍標準差
    func computeBOLL(candles: [CandleItems]) -> [Tech: [Double]]{
        var mb = [Double]()
        var up = [Double]()
        var dn = [Double]()
        for index in 0...candles.count - 1{
            //先算均線
            var mbSum: Double = 0
            for j in (index - 19)...index{
                let v: Double = Double(candles[max(0, j)].Close) ?? 0
                mbSum += v
            }
            let avg = mbSum / 20
            mb.append(avg)
            
            //算標準差
            var vSum: Double = 0
            for j in (index - 19)...index{
                let v: Double = (Double(candles[max(0, j)].Close) ?? 0) - avg
                let vPower2: Double = v * v
                vSum += vPower2
            }
            
            vSum /= 20
            let sd: Double = sqrt(vSum)
            
            //利用剛剛算出的標準差，把up和dn填進去
            up.append(avg + 2 * sd)
            dn.append(avg - 2 * sd)
        }
        
        return [.UP: up, .MB: mb, .DN: dn]
    }
    
    //MARK: -ARBR 情緒指標
    //N日AR = (N日內（H－O）之和）/(N日内（O－L）之和)*100
    //Ｎ日內BR = N日内（H－YC）之和）/N日内（YC－L）之和）*100
    //O為當日開盤價
    //H為當日最高價
    //L為當日最低價
    //YC為前一日交易的收盤價
    //N一般設為26日
    func computeARBR(candles: [CandleItems]) -> [Tech: [Double]]{
        var AR = [Double]()
        var BR = [Double]()
        print(candles)
        for index in 0 ... candles.count - 1{
            var hMinusOSum: Double = 0
            var oMinusLSum: Double = 0
            var hMinusYCSum: Double = 0
            var ycMinusLSum: Double = 0
            for j in (index - 25)...index{
                let hMinusO: Double = (Double(candles[max(0, j)].High) ?? 0) - (Double(candles[max(0, j)].Open) ?? 0)
                let oMinusL: Double = (Double(candles[max(0, j)].Open) ?? 0) - (Double(candles[max(0, j)].Low) ?? 0)
                hMinusOSum += hMinusO
                oMinusLSum += oMinusL
                
                let hMinusYC: Double = (Double(candles[max(0, j)].High) ?? 0) - (Double(candles[max(0, j)].Close) ?? 0)
                let ycMinusL: Double = (Double(candles[max(0, j)].Close) ?? 0) - (Double(candles[max(0, j)].Low) ?? 0)
                hMinusYCSum += hMinusYC
                ycMinusLSum += ycMinusL
            }
            AR.append(hMinusOSum/oMinusLSum * 100)
            BR.append(hMinusYCSum/ycMinusLSum * 100)
        }
     
        return [.AR: AR, .BR: BR]
        
    }
}
