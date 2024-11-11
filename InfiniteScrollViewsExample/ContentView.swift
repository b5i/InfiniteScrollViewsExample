//
//  ContentView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 14.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var startingIndex: Int = 0
    var body: some View {
        TabView {
            HorizonalView()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.left.and.right.text.vertical")
                        Text("Horizontal")
                    }
                }
            CalendarView()
                .tabItem {
                    VStack {
                        Image(systemName: "line.3.horizontal")
                        Text("Calendar")
                    }
                }
            
            PagedCalendarView()
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Paged calendar")
                    }
                }
            
            DayView()
                .tabItem {
                    VStack {
                        Image(systemName: "ellipsis")
                        Text("Days")
                    }
                }
            AutomaticLoadMoreView()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.2.squarepath")
                        Text("Automatic YouTube")
                    }
                }
        }
    }
}


extension Date {
    func getDayOfMonth() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        let dayOfMonth = components.day
        return dayOfMonth ?? 0
    }
    
    func getDayOfWeek() -> Int {
        return ((Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0) + 5) % 7
    }
    
    func addingXDays(x: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: x, to: self) ?? self
    }
    
    
    // https://stackoverflow.com/a/43664156/16456439
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}
