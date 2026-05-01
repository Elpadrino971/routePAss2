import SwiftUI

struct CalendarGridView: View {
    @Binding var selectedMonth: Date
    let status: RPStatus
    let occupiedUntil: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di"]

    var body: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(.subheadline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.system(.caption2, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textSecondary)
                        .frame(height: 24)
                }

                ForEach(daysInMonth, id: \.self) { date in
                    if let date {
                        let dayState = stateForDay(date)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(.caption, design: .default, weight: dayState == .available ? .semibold : .regular))
                            .foregroundStyle(dayState.textColor)
                            .frame(width: 36, height: 36)
                            .background(dayState.bgColor)
                            .clipShape(Circle())
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth).capitalized
    }

    private var daysInMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }

        var weekday = calendar.component(.weekday, from: firstDay) - 2
        if weekday < 0 { weekday += 7 }

        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            var dc = comps
            dc.day = day
            days.append(calendar.date(from: dc))
        }
        return days
    }

    private func stateForDay(_ date: Date) -> DayState {
        let today = calendar.startOfDay(for: Date())
        let day = calendar.startOfDay(for: date)

        if day < today { return .past }

        if let occupied = occupiedUntil {
            let occupiedDay = calendar.startOfDay(for: occupied)
            if day <= occupiedDay { return .occupied }
        }

        return .available
    }
}

private enum DayState {
    case past
    case available
    case occupied

    var textColor: Color {
        switch self {
        case .past: RPTheme.textSecondary.opacity(0.4)
        case .available: RPTheme.textPrimary
        case .occupied: .red
        }
    }

    var bgColor: Color {
        switch self {
        case .past: .clear
        case .available: Color.green.opacity(0.1)
        case .occupied: Color.red.opacity(0.1)
        }
    }
}
