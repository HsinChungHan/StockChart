//
//  String_Extension.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/24.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
extension String{
    func modifyTime() -> String{
        return replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
    }
}
