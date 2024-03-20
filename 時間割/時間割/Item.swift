//
//  Item.swift
//  時間割
//
//  Created by 杉本陽紀 on 2024/03/20.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
