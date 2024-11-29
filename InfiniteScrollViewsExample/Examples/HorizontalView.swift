//
//  HorizonalView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 14.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//

import SwiftUI
import InfiniteScrollViews

struct HorizonalView: View {
    @State private var startingIndex: Int = 0
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                InfiniteScrollView(
                    frame: .init(x: 0, y: 0, width: 300, height: 300),
                    changeIndex: startingIndex,
                    content: { changingIndex in
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(.primary)
                            Text("Current index is: \(changingIndex)")
                                .foregroundStyle(.background)
                        }
                        .padding()
                        .onTapGesture {
                            print("Tapped: \(changingIndex)")
                        }
                    },
                    contentFrame: { changingIndex in
                        return .init(x: 0, y: 300, width: 300, height: 300)
                    },
                    increaseIndexAction: {$0 + 1},
                    decreaseIndexAction: {$0 - 1},
                    orientation: .horizontal
                )
                .border(.white)
                Spacer()
            }
        }
    }
}

