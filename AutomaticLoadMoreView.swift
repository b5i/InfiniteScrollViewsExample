//
//  AutomaticLoadMoreView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 16.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import YouTubeKit
import CachedAsyncImage
import InfiniteScrollViews

struct AutomaticLoadMoreView: View {
    @ObservedObject private var model = YTModel.shared
    @State private var baseIndex: Int = 0
    
    /// Should redraw the elements on the screen? Useful when you have a loader and want to display new elements instead.
    @State private var shouldReloadInfiniteScrollView: Bool = false
    
    /// Should use the custom InfiniteScrollView component?
    @State private var customMode: Bool = true
    
    /// 0: Should stop the scroll? 1: At element index.
    @State private var shouldStopAt: (Bool, Int) = (true, 20) {
        willSet {
            if newValue.0 == true, shouldStopAt.0 == false {
                shouldReloadInfiniteScrollView = true
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Toggle("Custom ScrollView", isOn: $customMode)
                    .padding()
                Toggle("Stop at \(shouldStopAt.1) elements", isOn: $shouldStopAt.0)
                    .padding()
                #if os(macOS)
                Text("!!! Scroll to the top to fetch new results !!!")
                #endif
                if customMode {
                    VStack {
                        if model.response == nil {
                            ProgressView()
                        } else {
                            InfiniteScrollView(
                                frame: .init(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height * 0.8),
                                changeIndex: baseIndex,
                                content: { changeIndex in
                                    Group {
                                        if model.videos.count > changeIndex + 1 {
                                            VideoView(video: model.videos[changeIndex])
                                        }
                                    }
                                },
                                contentFrame: { _ in
                                    return .init(x: 0, y: 0, width: geometry.size.width, height: 205)
                                },
                                increaseIndexAction: { changeIndex in
                                    if changeIndex < model.videos.count - 1 {
                                        if shouldStopAt.0 && changeIndex > shouldStopAt.1 {
                                            return nil
                                        }
                                        if changeIndex + 5 >= model.videos.count - 1 {
                                            Task {
                                                await model.getMoreVideos()
                                                shouldReloadInfiniteScrollView = true
                                            }
                                        }
                                        return changeIndex + 1
                                    } else {
                                        return nil
                                    }
                                },
                                decreaseIndexAction: { changeIndex in
                                    if changeIndex > 0 {
                                        return changeIndex - 1
                                    } else {
                                        return nil
                                    }
                                },
                                orientation: .vertical,
                                refreshAction: { endAction in
                                    Task {
                                        await model.refreshVideos()
                                        shouldReloadInfiniteScrollView = true
                                        DispatchQueue.main.async {
                                            endAction()
                                        }
                                    }
                                },
                                updateBinding: $shouldReloadInfiniteScrollView
                            )
                        }
                    }
                    .onAppear {
                        Task {
                            await model.getMoreVideos()
                            shouldReloadInfiniteScrollView = true
                        }
                    }
                } else {
                    ScrollView(.vertical, content: {
                        LazyVStack {
                            ForEach(shouldStopAt.0 ? Array(model.videos.prefix(shouldStopAt.1).enumerated()) : Array(model.videos.enumerated()), id: \.offset) { _, content in
                                HStack {
                                    VideoView(video: content)
                                }
                                .frame(width: geometry.size.width, height: 200)
                            }
                        }
                    })
                }
            }
        }
    }
    
    private class YTModel: ObservableObject {
        static let shared = YTModel()
        
        let YTM = YouTubeModel()
        @Published var isQuerying: Bool = false
        @Published var response: SearchResponse? = nil
        
        var videos: [YTVideo] {
            return self.response?.results.compactMap({$0 as? YTVideo}) ?? []
        }
        
        func refreshVideos() async {
            self.response = nil
            await getMoreVideos()
        }
        
        func getMoreVideos() async {
            if self.isQuerying {
                return
            }
            print("Getting videos")
            DispatchQueue.main.async {
                self.isQuerying = true
            }
            if self.response != nil {
                let continuation = try? await self.response?.fetchContinuationThrowing(youtubeModel: YTM)
                guard let continuation = continuation else { print("Couldn't fetch continuation"); DispatchQueue.main.async { self.isQuerying = false }; return }
                DispatchQueue.main.async {
                    self.isQuerying = false
                    self.response?.mergeContinuation(continuation)
                }
            } else {
                let response = try? await SearchResponse.sendThrowingRequest(youtubeModel: YTM, data: [.query: "trending"])
                
                guard let response = response else { print("Couldn't fetch videos"); DispatchQueue.main.async { self.isQuerying = false }; return }
                DispatchQueue.main.async {
                    self.isQuerying = false
                    self.response = response
                }
            }
        }
    }
}
