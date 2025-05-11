//
//  Projects.UI.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Combine

extension Projects {

    struct UI: View {
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
                .navigationTitle("tab.repo")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    struct ContentView: View {

        @StateObject
        var vm: VM = .init()
        
        @State
        private var refresh: Bool = false
        
        let firstLaunch: PassthroughSubject<Bool, Never> = .init()

        var body: some View {
            LazyVStack(spacing: 15) {
                ForEach(self.vm.data.list) { item in
                    NavigationLink {
                        Webview()
                            .load(url: item.html_url)
                    } label: {
                        ContentCell(data: item)
                            .frame(maxWidth:.infinity, alignment:.leading)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .refreshable(firstLaunch: self.firstLaunch.eraseToAnyPublisher()) { index in
                try? await self.vm.fetch(index: index)
            }
            .onAppear {
                if A.user == nil {
                    self.vm.data = .init(list: [])
                    self.refresh.toggle()
                }
            }.onReceive(A.$user) { _ in
                if A.user != nil,
                   self.vm.data.list.count == 0 {
                    self.firstLaunch.send(true)
                }
            }
        }
    }

    struct ContentCell: View {
        
        var data: Projects.Model.Item
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center, spacing: 5) {
                    WebImage(url: .init(string: self.data.owner.avatar_url))
                        .resizable(resizingMode: .stretch)
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipShape(.circle)
                    Text(self.data.full_name)
                        .foregroundColor(.accent)
                }
                .frame(maxWidth:.infinity, alignment:.leading)
                if let bio = self.data.description {
                    Text(bio)
                }
                HStack(alignment: .center, spacing: 5) {
                    Image(systemName: "hammer")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 10, height: 10)
                    Text(self.data.language ?? "unknown")
                    Text("·")
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 10, height: 10)
                    Text("\(self.data.stargazers_count)")
                    Text("·")
                    Text("\(self.data.updated_at)")
                }
            }
            .padding(10)
            .background(Color.cellBg)
            .border(.gray, width: 1)
        }
    }
}
