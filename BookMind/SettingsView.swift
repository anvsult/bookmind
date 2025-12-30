//
//  SettingsView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import SwiftUI
import Foundation
import UserNotifications
import SafariServices

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var bookDataManager: BookDataManager
    
    @State private var showingResetAlert = false
    @State private var showingPermissionAlert = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingSupportForm = false
    
    // URLs for legal documents and support
    private let privacyPolicyURL = URL(string: "https://www.termsfeed.com/live/80f2253b-a0ac-4ee6-9097-dfae4347498c")!
    private let termsOfServiceURL = URL(string: "https://www.termsfeed.com/live/4fafa962-4f73-4b20-9f60-841630326974")!
    private let supportFormURL = URL(string: "https://1ax5q9z8.forms.app/book-mind-contact-form")!

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Enhanced Header with Gradient
                    headerSection
                    
                    // Settings Sections
                    VStack(spacing: 24) {
                        // Notifications Section
                        notificationsSection
                        
                        // Support & Privacy Section
                        supportSection
                        
                        // About Section
                        aboutSection
                        
                        // Reset Section
                        resetSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground).opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPrivacyPolicy) {
                SafariView(url: privacyPolicyURL)
            }
            .sheet(isPresented: $showingTermsOfService) {
                SafariView(url: termsOfServiceURL)
            }
            .sheet(isPresented: $showingSupportForm) {
                SafariView(url: supportFormURL)
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    bookDataManager.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your books and notes. This action cannot be undone.")
            }
            .onAppear {
                settingsManager.refreshNotificationPermission()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Background gradient container
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.15),
                                Color.blue.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                VStack(spacing: 20) {
                    // Icon with enhanced background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 8) {
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Manage reminders, notifications, and data reset")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .padding(.top, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        SettingsCard(
            icon: "bell.fill",
            iconColor: .blue,
            title: "Notifications",
            subtitle: "Stay on top of your reading schedule"
        ) {
            VStack(spacing: 16) {
                // Notification permission status
                if settingsManager.notificationPermissionStatus == .denied {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications Disabled")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)
                                
                                Text("Enable notifications in Settings to receive reading reminders")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        ModernButtonRow(
                            title: "Open Settings",
                            subtitle: "Go to system settings",
                            icon: "gearshape",
                            iconColor: .blue,
                            action: { settingsManager.openAppSettings() }
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                
                // Daily Reminders Toggle
                ModernToggleRow(
                    title: "Daily Reading Reminder",
                    subtitle: settingsManager.dailyReminderEnabled ?
                        "Reminder set for \(DateFormatter.timeFormatter.string(from: settingsManager.reminderTime))" :
                        "Get reminded to read daily",
                    isOn: $settingsManager.dailyReminderEnabled,
                    isDisabled: settingsManager.notificationPermissionStatus == .denied
                )
                
                // Reminder Time Picker
                if settingsManager.dailyReminderEnabled && settingsManager.notificationPermissionStatus != .denied {
                    ModernTimePickerRow(
                        title: "Reminder Time",
                        subtitle: "Choose when you want to be reminded",
                        selection: $settingsManager.reminderTime
                    )
                }
            }
        }
    }
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        SettingsCard(
            icon: "questionmark.circle.fill",
            iconColor: .green,
            title: "Support & Privacy",
            subtitle: "Get help and learn about your privacy"
        ) {
            VStack(spacing: 16) {
                // Privacy Policy
                ModernButtonRow(
                    title: "Privacy Policy",
                    subtitle: "Learn how we protect your data",
                    icon: "shield.checkered",
                    iconColor: .blue,
                    action: { showingPrivacyPolicy = true }
                )
                
                // Terms of Service
                ModernButtonRow(
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    icon: "doc.text.fill",
                    iconColor: .orange,
                    action: { showingTermsOfService = true }
                )
                
                // Contact Support
                ModernButtonRow(
                    title: "Contact Support",
                    subtitle: "Get help or send feedback",
                    icon: "envelope.fill",
                    iconColor: .green,
                    action: { showingSupportForm = true }
                )
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SettingsCard(
            icon: "info.circle.fill",
            iconColor: .teal,
            title: "About",
            subtitle: "App information and version details"
        ) {
            VStack(spacing: 16) {
                // App Version
                ModernInfoRow(
                    title: "App Version",
                    value: "1.0.0"
                )
                
                // App Name
                ModernInfoRow(
                    title: "App Name",
                    value: "BookMind"
                )
                
            }
        }
    }
    
    // MARK: - Reset Section
    
    private var resetSection: some View {
        SettingsCard(
            icon: "arrow.clockwise",
            iconColor: .red,
            title: "Reset Options",
            subtitle: "Reset settings and data"
        ) {
            VStack(spacing: 16) {
                // Reset All Data
                ModernButtonRow(
                    title: "Reset All Data",
                    subtitle: "Clear all books and notes (irreversible)",
                    icon: "trash.fill",
                    iconColor: .red,
                    action: { showingResetAlert = true }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func openEmailSupport() {
        let email = "support@bookmind.app"
        let subject = "BookMind Support"
        let body = "Hi BookMind team,\n\nI need help with:\n\n"
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Modern UI Components

struct SettingsCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, iconColor: Color, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Content
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
    }
}

struct ModernToggleRow: View {
    let title: String
    let subtitle: String
    let isOn: Binding<Bool>
    let onChange: ((Bool, Bool) -> Void)?
    let isDisabled: Bool
    
    init(title: String, subtitle: String, isOn: Binding<Bool>, onChange: ((Bool, Bool) -> Void)? = nil, isDisabled: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
        self.onChange = onChange
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .onChange(of: isOn.wrappedValue) { oldValue, newValue in
                    onChange?(oldValue, newValue)
                }
                .tint(.blue)
                .disabled(isDisabled)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct ModernButtonRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernTimePickerRow: View {
    let title: String
    let subtitle: String
    let selection: Binding<Date>
    let onChange: ((Date, Date) -> Void)?
    
    init(title: String, subtitle: String, selection: Binding<Date>, onChange: ((Date, Date) -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.selection = selection
        self.onChange = onChange
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .onChange(of: selection.wrappedValue) { oldValue, newValue in
                    onChange?(oldValue, newValue)
                }
                .labelsHidden()
                .scaleEffect(0.9)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct ModernInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    SettingsView()
}
