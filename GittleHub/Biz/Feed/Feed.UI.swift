//
//  FeedView.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

extension Feed {

    struct FeedsView: View {
        
        @EnvironmentObject
        var context: AppContext

        var body: some View {
            NavigationView {
                ZStack {
                    LoginEntry()
                    if self.context.user != nil {
                        VStack {
                            ContentView()
                        }
                        .padding(.bottom)
                    }
                }
                .navigationTitle("tab.home")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

    }
    
    struct ContentView: View {

        @StateObject
        var vm: VM = .init()
        
        @State
        private var refresh: Bool = false

        var body: some View {
            let view = ScrollView() {
                LazyVStack(spacing: 15) {
                    ForEach(self.vm.data.list) { item in
                        EventCell(data: item)
                    }
                }
            }.onAppear {
                if A.user == nil {
                    self.vm.data = .init(list: [])
                    self.refresh.toggle()
                }
            }.onReceive(A.$user) { _ in
                if A.user != nil,
                   self.vm.data.list.count == 0 {
                    Task {
                        try? await self.vm.fetch()
                        self.refresh.toggle()
                    }
                }
            }
            if #available(iOS 15.0, *) {
                return view.refreshable {
                    try? await self.vm.fetch()
                }
            } else {
                return view
            }
        }
        
        struct EventCell: View {
            
            var data: Feed.Model.Event

            var body: some View {
                HStack(spacing: 10) {
                    WebImage(url: .init(string: self.data.actor.avatar_url))
                        .resizable(resizingMode: .stretch)
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(.circle)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(self.data.actor.displayName)
                            .foregroundColor(.accent)
                            .font(.title3)
                        Text(self.data.operation)
                            .foregroundColor(.cellNormal)
                            .font(.title3)
                        Text(self.data.repo.name)
                            .foregroundColor(.accent)
                            .font(.title3)
                    }
                    Spacer()
                }
                .padding(20)
                .background(Color.cellBg)
                .border(.gray, width: 1)
            }
        }
        
        struct AttributedTextView: View {
            
            let attributedText: NSAttributedString
            
            init(attributedText: NSAttributedString) {
                self.attributedText = attributedText
            }
            
            var body: some View {
                if #available(iOS 15.0, *) {
                    Text(.init(attributedText))
                } else {
                    Before15(attributedText: self.attributedText)
                }
            }
            
            struct Before15: UIViewRepresentable {
                var attributedText: NSAttributedString
                func makeUIView(context: Context) -> UILabel {
                    let label = UILabel()
                    label.numberOfLines = 0
                    return label
                }
                func updateUIView(_ uiView: UILabel, context: Context) {
                    uiView.attributedText = attributedText
                }
            }
        }
    }

}

extension Feed.Model.Event {
    
    var operation: String {
        switch self.type {
        case .WatchEvent:
            switch self.payload.data {
            case .startedWatch:
                return "starred a repository"
            default:
                return "unstarred a repository"
            }
        case .ForkEvent:
            switch self.payload.data {
            case .fork:
                return "forked a repository"
            default:
                return "performed an event \(self.type.rawValue) with"
            }
        default:
            return "performed an event \(self.type.rawValue) with"
        }
    }
}
