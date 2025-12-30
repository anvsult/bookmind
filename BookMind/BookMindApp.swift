//
//  BookMind2App.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import SwiftUI
import SwiftData

@main
struct BookNotesApp: App {
    @StateObject private var bookDataManager = BookDataManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookDataManager)
                .environmentObject(settingsManager)
        }
    }
}

