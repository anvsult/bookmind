//
//  Item.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
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
