//
//  DayView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 15.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import InfiniteScrollViews

struct DayView: View {
    @State private var nowDate: Date = .now
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        ForEach(0..<7) { index in
                            Text(Calendar.current.shortWeekdaySymbols[index])
                                .font(.caption2)
                            if index != 6 {
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    #if os(macOS)
                    Text("PagedInfiniteScrollView is not implemented for macOS at the moment.")
                    /*
                    PagedInfiniteScrollView(
                        changeIndex: $nowDate,
                        content: { currentDate in
                            HStack {
                                Spacer()
                                let currentDayOfWeek = currentDate.getDayOfWeek()
                                ForEach(0..<7) { index in
                                    ZStack {
                                        let currentDayOfWeek = currentDate.getDayOfWeek()
                                        let isCurrentSameDay = Calendar.current.isDate(currentDate.addingXDays(x: (index - currentDayOfWeek)), inSameDayAs: .now)
                                        if currentDayOfWeek == index {
                                            Circle()
                                                .foregroundStyle(isCurrentSameDay ? .red : .white)
                                            Text(String(currentDate.addingXDays(x: (index - currentDayOfWeek)).getDayOfMonth()))
                                                .foregroundStyle(isCurrentSameDay ? .white : .black)
                                        } else {
                                            Circle()
                                                .opacity(0)
                                            Text(String(currentDate.addingXDays(x: (index - currentDayOfWeek)).getDayOfMonth()))
                                                .foregroundStyle(isCurrentSameDay ? .red : .white)
                                        }
                                    }
                                    .onTapGesture {
                                        nowDate = currentDate.addingXDays(x: (index - currentDayOfWeek))
                                    }
                                    if index != 6 {
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                }
                            }
                        },
                        increaseIndexAction: { currentDate in
                            return currentDate.addingXDays(x: 7)
                        },
                        decreaseIndexAction: { currentDate in
                            return currentDate.addingXDays(x: -7)
                        },
                        shouldAnimateBetween: { date1, date2 in
                            if date1 != date2 {
                                return shouldAnimateWithWeeks(currentDate: date1, nextDate: date2)
                            }
                            return false
                        },
                        transitionStyle: .stackHistory
                    )
                    .frame(height: geometry.size.height * 0.1)
                     */
                    #else
                    PagedInfiniteScrollView(
                        changeIndex: $nowDate,
                        content: { currentDate in
                            HStack {
                                Spacer()
                                let currentDayOfWeek = currentDate.getDayOfWeek()
                                ForEach(0..<7) { index in
                                    ZStack {
                                        let currentDayOfWeek = currentDate.getDayOfWeek()
                                        let isCurrentSameDay = Calendar.current.isDate(currentDate.addingXDays(x: (index - currentDayOfWeek)), inSameDayAs: .now)
                                        if currentDayOfWeek == index {
                                            Circle()
                                                .foregroundStyle(isCurrentSameDay ? .red : .blue)
                                            Text(String(currentDate.addingXDays(x: (index - currentDayOfWeek)).getDayOfMonth()))
                                                .foregroundStyle(isCurrentSameDay ? .blue : .primary)
                                        } else {
                                            Circle()
                                                .opacity(0)
                                            Text(String(currentDate.addingXDays(x: (index - currentDayOfWeek)).getDayOfMonth()))
                                                .foregroundStyle(isCurrentSameDay ? .red : .blue)
                                        }
                                    }
                                    .onTapGesture {
                                        nowDate = currentDate.addingXDays(x: (index - currentDayOfWeek))
                                    }
                                    if index != 6 {
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                }
                            }
                        },
                        increaseIndexAction: { currentDate in
                            return currentDate.addingXDays(x: 7)
                        },
                        decreaseIndexAction: { currentDate in
                            return currentDate.addingXDays(x: -7)
                        },
                        shouldAnimateBetween: { date1, date2 in
                            if date1 != date2 {
                                return shouldAnimateWithWeeks(currentDate: date1, nextDate: date2)
                            }
                            return (false, .forward)
                        },
                        transitionStyle: .scroll,
                        navigationOrientation: .horizontal
                    )
                    .frame(height: geometry.size.height * 0.1)
                    #endif
                }
                .frame(height: geometry.size.height * 0.1)
                #if os(macOS)
                Text("PagedInfiniteScrollView is not implemented for macOS at the moment.")

                /*
                PagedInfiniteScrollView(
                    changeIndex: $nowDate,
                    content: { day in
                        Text("Selected day is: \(day.formatted())")
                    },
                    increaseIndexAction: { currentDate in
                        return currentDate.addingXDays(x: 1)
                    },
                    decreaseIndexAction: { currentDate in
                        return currentDate.addingXDays(x: -1)
                    },
                    shouldAnimateBetween: { date1, date2 in
                        if date1 == date2 { return false }
                        return Calendar.current.isDate(date1, inSameDayAs: date2) ? false : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? true : true
                    },
                    transitionStyle: .stackHistory
                )
                 */
                #else
                PagedInfiniteScrollView(
                    changeIndex: $nowDate,
                    content: { day in
                        Text("Selected day is: \(day.formatted())")
                    },
                    increaseIndexAction: { currentDate in
                        return currentDate.addingXDays(x: 1)
                    },
                    decreaseIndexAction: { currentDate in
                        return currentDate.addingXDays(x: -1)
                    },
                    shouldAnimateBetween: { date1, date2 in
                        if date1 == date2 { return (false, .forward) }
                        return Calendar.current.isDate(date1, inSameDayAs: date2) ? (false, .forward) : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? (true, .reverse) : (true, .forward)
                    },
                    transitionStyle: .pageCurl,
                    navigationOrientation: .horizontal
                )
                #endif
            }
        }
    }
    
    #if os(macOS)
    private func shouldAnimateWithWeeks(currentDate: Date, nextDate: Date) -> Bool {
        let cal = Calendar.current
        if cal.isDate(currentDate, inSameDayAs: nextDate) {
            return false
        }
        let currentComponents = cal.dateComponents([.year, .weekOfYear], from: currentDate)
        let nextComponents = cal.dateComponents([.year, .weekOfYear], from: nextDate)
        if currentComponents.year == nextComponents.year, currentComponents.weekOfYear == nextComponents.weekOfYear {
            return false
        }
        return true
        
    }
    #else
    private func shouldAnimateWithWeeks(currentDate: Date, nextDate: Date) -> (Bool, UIPageViewController.NavigationDirection) {
        let cal = Calendar.current
        if cal.isDate(currentDate, inSameDayAs: nextDate) {
            return (false, .forward)
        }
        let currentComponents = cal.dateComponents([.year, .weekOfYear], from: currentDate)
        let nextComponents = cal.dateComponents([.year, .weekOfYear], from: nextDate)
        if currentComponents.year == nextComponents.year, currentComponents.weekOfYear == nextComponents.weekOfYear {
            return (false, .forward)
        }
        return (true, currentDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 ? .reverse : .forward)
        
    }
    #endif
}
