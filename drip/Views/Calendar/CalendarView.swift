//
//  CalendarView.swift
//  drip
//

import SwiftData
import SwiftUI

let monthHeight: CGFloat = 400
struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var logs: [OutfitLog]

    @State private var selectedDate: Date?

    private let currentMonthStart: Date

    
    @State private var months: [Month] = []
    @State private var scrollPosition: ScrollPosition = .init()
    init() {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        self.currentMonthStart = start
        
    }
    /// infinite scroll props
    @State private var isLoadingTop: Bool = false
    @State private var isLoadingBottom: Bool = false
    @State private var isResetting: Bool = false
    
    private var yearTitle: String {
        currentMonthStart.formatted(.dateTime.year())
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical){
                LazyVStack {
                ForEach(months) { month in
                    MonthView(month: month, logs: logs) { date in
                        selectedDate = date
                    }
                    .frame(height: monthHeight)
                }
                }
            }
            .scrollPosition($scrollPosition)
            .defaultScrollAnchor(.center)
            .onScrollGeometryChange(
                for: ScrollInfo.self,
                of: {
                    let offsetY = $0.contentOffset.y + $0.contentInsets.top
                    let contentHeight = $0.contentSize.height
                    let containerHeight = $0.containerSize.height
                    
                    return .init(
                        offsetY: offsetY,
                        contentHeight: contentHeight,
                        containerHeight: containerHeight
                    )
                },
                action: { oldValue, newValue in
                    guard months.count >= 10 && !isResetting else { return }
                    
                    let threshold: CGFloat = 100
                    let offsetY = newValue.offsetY
                    let contentHeight = newValue.contentHeight
                    let frameHeight = newValue.containerHeight
                    
                    if offsetY > (contentHeight - frameHeight - threshold) && !isLoadingBottom {
                        loadFutureMonths(info: newValue)
                    }
                    
                    if offsetY < threshold && !isLoadingTop {
                        loadPastMonths(info: newValue)
                    }
            })
            .onAppear {
                guard months.isEmpty else { return }
                loadInitialData()
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0){
                symbolView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(yearTitle)
                        }
                        .fontWeight(.medium)
                    }
                }
            }
            .sheet(item: $selectedDate) { date in
                DayDetailView(date: date)
            }
        }
    }
    
    @ViewBuilder
    func symbolView() -> some View {
        HStack {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self){ symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .background(.ultraThinMaterial)
    }
    
    private func loadFutureMonths(info: ScrollInfo){
        isLoadingBottom = true
        let futureMonths = months.createMonths(10, isPast: false)
        months.append(contentsOf: futureMonths)
        
        if months.count > 30 {
            adjustScrollContentOffset(removesTop: true, info: info)
        }
        /// Resetting status in DispatchQueue
        DispatchQueue.main.async {
            isLoadingBottom = false
        }
    
    }
    
    private func loadPastMonths(info: ScrollInfo){
        isLoadingTop = true
        let pastMonths = months.createMonths(10, isPast: true)
        months.insert(contentsOf: pastMonths, at: 0)
        adjustScrollContentOffset(removesTop: false, info: info)
        
        /// Resetting status in DispatchQueue
        DispatchQueue.main.async {
            isLoadingTop = false
        }
    }
    
    private func adjustScrollContentOffset(removesTop: Bool, info: ScrollInfo){
        let previousContentHeight = info.contentHeight
        let preiousContentOffset = info.offsetY
        let adjustmentHeight: CGFloat = monthHeight * 10
        
        if removesTop {
            months.removeFirst(10)
        } else {
            if months.count > 30 { months.removeLast(10) }
        }
        
        let newContentHeight = previousContentHeight + (removesTop ? -adjustmentHeight : adjustmentHeight)
        
        let newContentOffset = preiousContentOffset + (newContentHeight - previousContentHeight)
        
        var transaction = Transaction()
        transaction.scrollPositionUpdatePreservesVelocity = true
        withTransaction(transaction) {
            scrollPosition.scrollTo(y: newContentOffset)
        }
    }
    
    private func loadInitialData(){
        guard months.isEmpty else { return }
        months = Date.now.initialLoadMonths
        let centerOffset = (CGFloat(months.count / 2) * monthHeight) - (monthHeight / 2)
        scrollPosition.scrollTo(y: centerOffset)
    }

}

struct MonthView: View {
    var month: Month
    var logs: [OutfitLog]
    var onDayTapped: (Date) -> Void

    private let calendar = Calendar.current

    private var plannedDays: Set<DateComponents> {
        Set(logs.filter { $0.type == .planned }.map {
            calendar.dateComponents([.year, .month, .day], from: $0.date)
        })
    }

    private var wornDays: Set<DateComponents> {
        Set(logs.filter { $0.type == .worn }.map {
            calendar.dateComponents([.year, .month, .day], from: $0.date)
        })
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(month.name)
                .font(.title2)
                .fontWeight(.bold)
                .frame(height: 50, alignment: .bottom)

            VStack {
                ForEach(month.weeks) { week in
                    HStack {
                        ForEach(week.days) { day in
                            if let date = day.date, !day.isPlaceholder {
                                let key = calendar.dateComponents([.year, .month, .day], from: date)
                                DayView(day: day, hasPlanned: plannedDays.contains(key), hasWorn: wornDays.contains(key))
                                    .onTapGesture { onDayTapped(date) }
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .bottom) {
                        if !week.isLast {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 15)
    }
}

struct DayView: View {
    var day: Day
    var hasPlanned: Bool = false
    var hasWorn: Bool = false

    var body: some View {
        if let dayValue = day.value, let date = day.date, !day.isPlaceholder {
            let isToday = Calendar.current.isDateInToday(date)

            VStack(spacing: 4) {
                Text("\(dayValue)")
                    .font(.callout)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(isToday ? .white : .primary)
                    .frame(width: 30, height: 30)
                    .background {
                        if isToday {
                            Circle()
                                .fill(.accent.gradient)
                        }
                    }

                HStack(spacing: 3) {
                    if hasPlanned {
                        Circle()
                            .fill(.accent)
                            .frame(width: 5, height: 5)
                    }
                    if hasWorn {
                        Circle()
                            .fill(.green)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        } else {
            Color.clear
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(PreviewData.previewContainer)
}
