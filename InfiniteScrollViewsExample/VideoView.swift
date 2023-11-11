//
//  VideoView.swift
//  InfiniteScrollViewsExample
//
//  Created by Antoine Bollengier on 11.11.2023.
//

import Foundation
import SwiftUI
import YouTubeKit
import CachedAsyncImage

struct VideoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var video: YTVideo
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 3) {
                VStack {
                    if let thumbnailURL = URL(string: "https://i.ytimg.com/vi/\(video.videoId)/hqdefault.jpg") {
                        CachedAsyncImage(url: thumbnailURL) { image in
                            if let croppedImage = cropImage(image) {
                                croppedImage
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(16/9, contentMode: .fit)
                            } else {
                                ZStack {
                                    ProgressView()
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.clear)
                                        .aspectRatio(16/9, contentMode: .fit)
                                }
                            }
                        } placeholder: {
                            ZStack {
                                ProgressView()
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.clear)
                                    .aspectRatio(16/9, contentMode: .fit)
                            }
                        }
                        .overlay(alignment: .bottomTrailing, content: {
                            if let timeLenght = video.timeLength {
                                if timeLenght == "live" {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.red)
                                        HStack {
                                            Image(systemName: "antenna.radiowaves.left.and.right")
                                            Text("Livestream")
                                        }
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                    }
                                    .frame(width: 100, height: 20)
                                    .padding(3)
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .opacity(0.9)
                                            .foregroundColor(.black)
                                        Text(timeLenght)
                                            .bold()
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: CGFloat(timeLenght.count) * 10, height: 20)
                                    .padding(3)
                                }
                            }
                        })
                        .frame(width: geometry.size.width * 0.52, height: geometry.size.height * 0.7)
                        .shadow(radius: 3)
                    }
                    HStack {
                        VStack {
                            if let viewCount = video.viewCount {
                                Text(viewCount)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.footnote)
                                    .opacity(0.5)
                                    .padding(.top, (video.timePosted != nil) ? -2 : -15)
                                if video.timePosted != nil {
                                    Divider()
                                        .padding(.leading)
                                        .padding(.top, -6)
                                }
                            }
                            if let timePosted = video.timePosted {
                                Text(timePosted)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.footnote)
                                    .opacity(0.5)
                                    .padding(.top, -12)
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.15)
                    .padding(.top, 1)
                }
                .frame(width: geometry.size.width * 0.52, height: geometry.size.height)
                VStack {
                    Text(video.title ?? "")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .truncationMode(.tail)
                        .frame(height: geometry.size.height * 0.7)
                    if let channelName = video.channel?.name {
                        Divider()
                        Text(channelName)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .bold()
                            .font(.footnote)
                            .opacity(0.5)
                    }
                }
                .frame(width: geometry.size.width * 0.475, height: geometry.size.height)
            }
        }
    }
    
    // Inspired from https://developer.apple.com/documentation/coregraphics/cgimage/1454683-cropping
    @MainActor private func cropImage(_ inputImage: Image) -> Image? {
        // Extract UIImage from Image
        guard #available(iOS 16.0, *), let uiImage = ImageRenderer(content: inputImage).uiImage else { return nil }
        let portionToCut = (uiImage.size.height - uiImage.size.width * 9/16) / 2
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x: 0,
                              y: portionToCut,
                              width: uiImage.size.width,
                              height: uiImage.size.height - portionToCut * 2)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = uiImage.cgImage?.cropping(to: cropZone)
        else {
            return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return Image(uiImage: croppedImage)
    }
}
