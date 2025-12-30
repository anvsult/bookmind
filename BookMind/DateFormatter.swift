//
//  DateFormatter.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
