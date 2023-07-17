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
}
