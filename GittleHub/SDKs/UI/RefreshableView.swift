//
//  RefreshableView.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/12.
//

import Foundation
import SwiftUI
import Combine

struct RefreshableViewModifier: ViewModifier {
    
    struct TopPositionKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    }
    struct BottomPositionKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    }

    @State
    var isRefreshing: Bool = false
    @State
    var isLoadingMore: Bool = false
    @State
    private var pageIndex = 0

    @State
    private var scrollOffset: CGFloat = 0
    @State
    private var contentHeight: CGFloat = 0

    let refreshThreshold: CGFloat = 60

    let requestData: (Int) async -> Void
    let firstLaunch: AnyPublisher<Bool, Never>

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollView {
                    VStack {
                        Color.clear
                            .frame(height: 1)
                            .background(
                                GeometryReader { topP in
                                    Color.clear.preference(key: TopPositionKey.self,value: topP.frame(in: .named("scrollView")).minY)
                                }
                            )
                        content
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(key: BottomPositionKey.self, value: proxy.size.height)
                                }
                            )
                        if self.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .frame(width: 30, height: 30, alignment: .center)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
                .coordinateSpace(name: "scrollView")
                .frame(width: geometry.size.width, height: geometry.size.height)
                .disabled(isRefreshing)
                .onPreferenceChange(TopPositionKey.self) { value in
                    self.scrollOffset = value
                    if geometry.size.height > 0,
                       self.scrollOffset < 0,
                       geometry.size.height - self.scrollOffset > self.contentHeight,
                       !self.isRefreshing,
                       !self.isLoadingMore {
                        Task { @MainActor in
                            self.isLoadingMore = true
                            Task {
                                self.pageIndex += 1
                                await self.requestData(self.pageIndex)
                                await MainActor.run {
                                    self.isLoadingMore = false
                                }
                            }
                        }
                    }
                }
                .onPreferenceChange(BottomPositionKey.self) { value in
                    self.contentHeight = value
                }
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { value in
                            if !self.isRefreshing,
                               !self.isLoadingMore,
                               self.scrollOffset > self.refreshThreshold {
                                Task { @MainActor in
                                    self.isRefreshing = true
                                    Task {
                                        self.pageIndex = 1
                                        await self.requestData(self.pageIndex)
                                        await MainActor.run {
                                            self.isRefreshing = false
                                        }
                                    }
                                }
                            }
                        }
                )
                
                if self.isRefreshing || self.scrollOffset > 0 {
                    HStack {
                        Spacer()
                        if isRefreshing {
                            ProgressView()
                                .frame(width: 30, height: 30, alignment: .center)
                        } else {
                            Image(systemName: "arrow.down")
                                .rotationEffect(.degrees(scrollOffset > self.refreshThreshold ? 180 : 0))
                        }
                        Spacer()
                    }
                    .animation(.spring(), value: self.scrollOffset)
                }
            }
            .onReceive(self.firstLaunch.debounce(for: 0.1, scheduler: RunLoop.main)) { value in
                Task {
                    await MainActor.run {
                        self.isRefreshing = true
                    }
                    self.pageIndex = 1
                    await self.requestData(self.pageIndex)
                    await MainActor.run {
                        self.isRefreshing = false
                    }
                }
            }
        }
    }
}

extension View {
    func refreshable(firstLaunch: AnyPublisher<Bool, Never>, requestData: @escaping (Int) async -> Void) -> some View {
        modifier(RefreshableViewModifier(requestData: requestData, firstLaunch: firstLaunch))
    }
}
