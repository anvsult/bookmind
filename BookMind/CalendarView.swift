import SwiftUI
import Foundation


struct CalendarView: View {
    @EnvironmentObject var bookDataManager: BookDataManager
    @State private var selectedDate: Date = Date()

    private var readingDaysThisMonth: Int {
        let calendar = Calendar.current
        let today = Date()

        // Get the start and end of this month
        guard let range = calendar.range(of: .day, in: .month, for: today),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let monthEnd = calendar.date(byAdding: .day, value: range.count - 1, to: monthStart)
        else { return 0 }

        // Convert DateComponents -> Date and filter
        let entries = bookDataManager.getDatesWithEntries().compactMap {
            calendar.date(from: $0)
        }

        let monthEntries = entries.filter { date in
            date >= monthStart && date <= monthEnd
        }

        // Unique days only
        let uniqueDays = Set(monthEntries.map { calendar.startOfDay(for: $0) })
        return uniqueDays.count
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                ZStack (alignment: .leading){
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.3), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reading Calendar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("You have read on \(readingDaysThisMonth) day\(readingDaysThisMonth == 1 ? "" : "s") this month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .frame(height: 120)

                // Calendar Grid
                CustomCalendarView(
                    selectedDate: $selectedDate,
                    datesWithEntries: bookDataManager.getDatesWithEntries()
                )
                .padding()

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}


struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let datesWithEntries: Set<DateComponents>

    private let calendar = Calendar.current

    private var daysInMonth: [Date?] {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let days = range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }

        return Array(repeating: nil, count: firstWeekday) + days
    }

    var body: some View {
        VStack {
            // Month/Year header
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(for: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // Weekday labels
            let symbols = calendar.shortWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }

            // Grid of days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        let comps = calendar.dateComponents([.year, .month, .day], from: date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let hasEntry = datesWithEntries.contains(comps)

                        VStack(spacing: 4) {
                            Text("\(calendar.component(.day, from: date))")
                                .frame(maxWidth: .infinity)
                                .padding(6)
                                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Circle())

                            if hasEntry {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .onTapGesture {
                            selectedDate = date
                        }

                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                            .padding(6)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    // Helpers
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
