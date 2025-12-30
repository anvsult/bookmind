//
//  SettingsManager.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation
import UserNotifications
import SwiftUI

class SettingsManager: ObservableObject {
    @Published var dailyReminderEnabled = false {
        didSet {
            if dailyReminderEnabled != oldValue {
                handleNotificationToggle()
            }
        }
    }
    
    @Published var reminderTime = Date() {
        didSet {
            if dailyReminderEnabled {
                scheduleNotification()
            }
        }
    }
    
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "dailyReadingReminder"
    
    init() {
        loadSettings()
        checkNotificationPermission()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(dailyReminderEnabled, forKey: "DailyReminderEnabled")
        UserDefaults.standard.set(reminderTime, forKey: "ReminderTime")
    }
    
    private func loadSettings() {
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "DailyReminderEnabled")
        if let savedTime = UserDefaults.standard.object(forKey: "ReminderTime") as? Date {
            reminderTime = savedTime
        } else {
            // Default to 7:00 PM
            let calendar = Calendar.current
            let now = Date()
            reminderTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now) ?? now
        }
    }
    
    private func checkNotificationPermission() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    private func handleNotificationToggle() {
        if dailyReminderEnabled {
            requestNotificationPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.scheduleNotification()
                        self?.saveSettings()
                    } else {
                        self?.dailyReminderEnabled = false
                    }
                }
            }
        } else {
            cancelNotification()
            saveSettings()
        }
    }
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.checkNotificationPermission()
                completion(granted && error == nil)
            }
        }
    }
    
    private func scheduleNotification() {
        // Cancel existing notification first
        cancelNotification()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Read! 📚"
        content.body = "Don't forget to spend some time with your books today."
        content.sound = .default
        content.badge = 1
        
        // Create time-based trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily reading reminder scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
            }
        }
    }
    
    private func cancelNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("Daily reading reminder cancelled")
    }
    
    func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    // Public method to manually refresh notification permission status
    func refreshNotificationPermission() {
        checkNotificationPermission()
    }
    
    // Public method to open app settings
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
