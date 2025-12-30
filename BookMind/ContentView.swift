//
//  ContentView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var bookDataManager: BookDataManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        TabView {
            MyLibraryView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("My Library")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
        .onAppear {
            settingsManager.clearNotificationBadge()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            settingsManager.clearNotificationBadge()
        }
    }
}
