//
//  CalendarRepresentable.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//
import Foundation
import SwiftUI

struct CalendarRepresentable: UIViewRepresentable {
    @Binding var selectedDate: Date
    let datesWithEntries: Set<DateComponents>
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = context.coordinator
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture)
        calendarView.fontDesign = .rounded
        
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Update the coordinator with fresh data
        context.coordinator.updateDates(datesWithEntries)
        
        // Reload decorations for the dates we have
        uiView.reloadDecorations(forDateComponents: Array(datesWithEntries), animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        let parent: CalendarRepresentable
        var currentDatesWithEntries: Set<DateComponents> = []
        
        init(_ parent: CalendarRepresentable) {
            self.parent = parent
        }
        
        func updateDates(_ dates: Set<DateComponents>) {
            currentDatesWithEntries = dates
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let dateComponents = dateComponents,
               let date = Calendar.current.date(from: dateComponents) {
                parent.selectedDate = date
            }
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if currentDatesWithEntries.contains(dateComponents) {
                return .image(UIImage(systemName: "circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal))
            }
            return nil
        }
        
    }
}
