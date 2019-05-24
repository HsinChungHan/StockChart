//
//  CandleItem.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation

struct CandlesModel: Codable {
    var candleItems: [CandleItems]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var tempItem: [CandleItems] = []
        
        while !container.isAtEnd {
            let item = try container.decode(CandleItems.self)
            tempItem.append(item)
        }
        
        candleItems = tempItem
    }
}

struct CandleItems: Codable {
    let Close: String
    let High: String
    let Key: String
    let Low: String
    let Open: String
    let Time: String
    
    func translateTime() -> String{
        return Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "/n")
    }
}
