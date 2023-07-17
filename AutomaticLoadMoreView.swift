//
//  AutomaticLoadMoreView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 16.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import YouTubeKit
import InfiniteScrollViews

struct AutomaticLoadMoreView: View {
    @ObservedObject private var model = YTModel()
    @State private var baseIndex: Int = 0
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Scroll a bit")
                InfiniteScrollView(
                    frame: .init(x: 0, y: 0, width: geometry.size.width, height: 300),
                    changeIndex: baseIndex,
                    content: { changingIndex in
                        HStack {
                            if let video = model.videos[changingIndex] as? YTVideo {
                                AsyncImage(url: video.thumbnails.last?.url) { result in
                                    switch result {
                                    case .empty:
                                        Text("No image")
                                    case .success(let image):
                                        image.resizable().scaledToFit()
                                    case .failure(let error):
                                        Text(error.localizedDescription)
                                    @unknown default:
                                        Color.clear.frame(width: 0, height: 0)
                                    }
                                }
                                VStack {
                                    Text(video.title ?? "No title")
                                        .font(.title3)
                                    Text(video.channel.name ?? "No channel name")
                                }
                            }
                        }
                    },
                    contentFrame: { changingIndex in
                        return .init(x: 0, y: 0, width: geometry.size.width, height: 300)
                    },
                    increaseIndexAction: { newDateInfos in
                        if newDateInfos < model.videos.count - 1 {
                            if newDateInfos + 5 >= model.videos.count - 1 {
                                Task {
                                    await model.getMoreVideos()
                                }
                            }
                            return newDateInfos + 1
                        } else {
                            return nil
                        }
                    },
                    decreaseIndexAction: { newDateInfos in
                        if newDateInfos > 0 {
                            return newDateInfos - 1
                        } else {
                            return nil
                        }
                    },
                    orientation: .vertical
                )
            }
            .onAppear {
                Task {
                    await model.getMoreVideos()
                }
            }
        }
    }
    
    private class YTModel: ObservableObject {
        let YTM = YouTubeModel()
        @Published var isQuerying: Bool = false
        @Published var videos: [any YTSearchResult] = []
        var tokens: (String, String)?
        
        
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
                guard let result = result else { print("Coulnd't fetch error?: \(error?.localizedDescription)"); DispatchQueue.main.async { self.isQuerying = false }; return }
                if let continuationToken = result.continuationToken {
                    self.tokens?.0 = continuationToken
                }
                DispatchQueue.main.async {
                    self.videos.append(contentsOf: result.results)
                    self.isQuerying = false
                }
            } else {
                let (result, error) = await HomeScreenResponse.sendRequest(youtubeModel: YTM, data: [:])
                guard let result = result else { print("Coulnd't fetch error?: \(error?.localizedDescription)"); DispatchQueue.main.async { self.isQuerying = false }; return }
                if let continuationToken = result.continuationToken, let visitorData = result.visitorData {
                    self.tokens = (continuationToken, visitorData)
                }
                DispatchQueue.main.async {
                    self.videos = result.results
                    self.isQuerying = false
                }
            }
        }
    }
}
