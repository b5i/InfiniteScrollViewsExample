//
//  AutomaticLoadMoreView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 16.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import YouTubeKit
import InfiniteScrollViews
import CachedAsyncImage

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
                if customMode {
                    VStack {
                        if model.videos.count == 0 {
                            ProgressView()
                        } else {
                            InfiniteScrollView(
                                frame: .init(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height * 0.8),
                                changeIndex: baseIndex,
                                content: { changeIndex in
                                    Group {
                                        if model.videos.count > changeIndex + 1, let video = model.videos[changeIndex] as? YTVideo {
                                            VideoView(video: video)
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
                                    if let video = content as? YTVideo {
                                        VideoView(video: video)
                                    }
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
        @Published var videos: [any YTSearchResult] = []
        var tokens: (String, String)?
        
        func refreshVideos() async {
            tokens = nil
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
            if let tokens = tokens {
                let (result, error) = await HomeScreenResponse.Continuation.sendRequest(youtubeModel: YTM, data: [.continuation: tokens.0, .visitorData: tokens.1])
                guard let result = result else { print("Coulnd't fetch error?: \(String(describing: error?.localizedDescription))"); DispatchQueue.main.async { self.isQuerying = false }; return }
                if let continuationToken = result.continuationToken {
                    self.tokens?.0 = continuationToken
                }
                DispatchQueue.main.async {
                    self.videos.append(contentsOf: result.results)
                    self.isQuerying = false
                }
            } else {
                let (result, error) = await HomeScreenResponse.sendRequest(youtubeModel: YTM, data: [:])
                guard let result = result else { print("Coulnd't fetch error?: \(String(describing: error?.localizedDescription))"); DispatchQueue.main.async { self.isQuerying = false }; return }
                if let continuationToken = result.continuationToken, let visitorData = result.visitorData {
                    self.tokens = (continuationToken, visitorData)
                }
                DispatchQueue.main.async {
                    /// Refresh UI.
                    self.videos = []
                    DispatchQueue.main.async {
                        self.videos = result.results
                        self.isQuerying = false
                    }
                }
            }
        }
    }
}
