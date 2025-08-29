//
//  PagedCalendarView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 15.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import InfiniteScrollViews

struct PagedCalendarView: View {
    @State private var nowDate: Date = .now
    var body: some View {
        #if os(macOS)
        PagedInfiniteScrollView(
            changeIndex: $nowDate,
            content: { month in
                CalendarView.MonthView(date: month)
            },
            increaseIndexAction: { currentDate in
                return currentDate.addingXDays(x: 30)
            },
            decreaseIndexAction: { currentDate in
                return currentDate.addingXDays(x: -30)
            },
            shouldAnimateBetween: { oldDate, newDate in
                return oldDate.isInSameDay(as: newDate) ? (false, .trailing) : oldDate.timeIntervalSince1970 < newDate.timeIntervalSince1970 ? (true, .trailing) : (true, .leading)
            }, indexesEqual: {
                $0.isInSameMonth(as: $1)
            }
        )
        #else
        PagedInfiniteScrollView(
            changeIndex: $nowDate,
            content: { month in
                CalendarView.MonthView(date: month)
            },
            increaseIndexAction: { currentDate in
                return currentDate.addingXDays(x: 30)
            },
            decreaseIndexAction: { currentDate in
                return currentDate.addingXDays(x: -30)
            },
            shouldAnimateBetween: { date1, date2 in
                if date1 == date2 { return (false, .forward) }
                return Calendar.current.isDate(date1, inSameDayAs: date2) ? (false, .forward) : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? (true, .reverse) : (true, .forward)
            },
            transitionStyle: .scroll,
            navigationOrientation: .vertical
        )
        .background {
            // test new areIndexesEqualAction compatibility
            // case not equatable and no areIndexesEqualAction given -> warning
            
            PagedInfiniteScrollView(
                changeIndex: .constant({} as (() -> Void)),
                content: { month in
                    CalendarView.MonthView(date: .now)
                },
                increaseIndexAction: { currentDate in
                    return {}
                },
                decreaseIndexAction: { currentDate in
                    return {}
                },
                shouldAnimateBetween: { date1, date2 in
                    return (false, .forward)
                },
                transitionStyle: .scroll,
                navigationOrientation: .vertical
            )
            .hidden()
            
            // case not equatable and areIndexesEqualAction given -> no warning
            
            PagedInfiniteScrollView(
                changeIndex: .constant({} as (() -> Void)),
                content: { month in
                    CalendarView.MonthView(date: .now)
                },
                increaseIndexAction: { currentDate in
                    return {}
                },
                decreaseIndexAction: { currentDate in
                    return {}
                },
                areIndexesEqualAction: {_, _ in return false},
                shouldAnimateBetween: { date1, date2 in
                    return (false, .forward)
                },
                transitionStyle: .scroll,
                navigationOrientation: .vertical
            )
            .hidden()
        }
        #endif
    }
}
