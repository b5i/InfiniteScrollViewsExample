//
//  CalendarView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 15.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import InfiniteScrollViews

struct CalendarView: View {
    @State private var dateInfos: (Int, Int) = (Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023, Calendar.current.dateComponents([.month], from: Date.now).month ?? 7)
    @State private var nowDate: Date = .now
    var body: some View {
        VStack {
            GeometryReader { geometry in
                InfiniteScrollView(
                    frame: .init(x: 0, y: 0, width: 200, height: 300),
                    changeIndex: dateInfos,
                    content: { changingIndex in
                        GeometryReader { geometry in
                            MonthView(dateInfos: changingIndex)
                                .padding()
                        }
                    },
                    contentFrame: { changingIndex in
                        return .init(x: 0, y: 0, width: 200, height: 300)
                    },
                    increaseIndexAction: { newDateInfos in
                        if newDateInfos.1 == 12 {
                            return (newDateInfos.0 + 1, 1)
                        } else {
                            return (newDateInfos.0, newDateInfos.1 + 1)
                        }
                    },
                    decreaseIndexAction: { newDateInfos in
                        if newDateInfos.1 == 1 {
                            return (newDateInfos.0 - 1, 12)
                        } else {
                            return (newDateInfos.0, newDateInfos.1 - 1)
                        }
                    },
                    orientation: .vertical
                )
            }
        }
    }
    
    struct MonthView: View {
        @State var dateInfos: (Int, Int)
        init(dateInfos: (Int, Int)) {
            self.dateInfos = dateInfos
        }
        init(date: Date) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: date)
            self.dateInfos = (components.year ?? 2023, components.month ?? 7)
        }
        private var daysInMonth: [[Int]] {
            let dateComponents = DateComponents(year: dateInfos.0, month: dateInfos.1)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!
            
            var rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)!
            let dateComponentsDayFirstWeek = DateComponents(year: dateInfos.0, month: dateInfos.1, weekOfMonth: 0)
            let dateDayFirstWeek = calendar.date(from: dateComponentsDayFirstWeek)!
            
            let rangeDayFirstWeek = calendar.range(of: .day, in: .weekOfMonth, for: dateDayFirstWeek)!
            var daysInMonth: [[Int]] = [Array(rangeDayFirstWeek)]
            rangeOfDaysInMonth.removeFirst(rangeDayFirstWeek.count)
            while rangeOfDaysInMonth.count > 0 {
                let toRemove: Int = (rangeOfDaysInMonth.count > 6 ? 7 : rangeOfDaysInMonth.count)
                let toAppend: [Int] = Array(rangeOfDaysInMonth.prefix(toRemove))
                daysInMonth.append(toAppend)
                rangeOfDaysInMonth.removeFirst(toRemove)
            }
            return daysInMonth
        }
        var body: some View {
            VStack {
                HStack {
                    Text(Calendar.current.monthSymbols[dateInfos.1 - 1])
                    Text(String(dateInfos.0))
                }
                ForEach(daysInMonth, id: \.self) { week in
                    HStack {
                        ForEach(week, id: \.self) { dayInWeek in
                            Text(String(dayInWeek))
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
        }
    }
}
