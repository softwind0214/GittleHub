//
//  Search.UI.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

extension Search {
    
    @available(iOS 15.0, *)
    struct UI: View {

        @State private var searchText = ""
        @State private var isLoading = false
        @FocusState private var isSearchFieldFocused: Bool
        
        @EnvironmentObject
        var vm: Search.VM

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // 搜索框
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("search.input.placeholder", text: $searchText)
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 4)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ScrollView {
                        VStack {
                            if isLoading {
                                ProgressView()
                                    .padding(.top, 40)
                            } else if let result = self.vm.result,
                                      result.items.count > 0 {
                                ForEach(result.items, id: \.id) { item in
                                    Item(data: item)
                                        .frame(maxWidth:.infinity, alignment:.leading)
                                        .background(Color(.systemBackground))
                                        .padding(.horizontal)
                                        .accessibilityLabel("ui-test-\(item.id)")
                                }
                            } else {
                                Spacer() // 顶部占位
                                Text(searchText.isEmpty ? "search.tips.empty" : "search.tips.noresult")
                                    .foregroundColor(.gray)
                                Spacer() // 底部占位
                            }
                        }
                        .frame(minHeight: UIScreen.main.bounds.height * 0.7) // 至少占据 70% 屏幕高度
                    }
                    .padding(.top, 4)
                    .padding(.bottom)
                }
                .navigationTitle("tab.search")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        Button("nav.search.tool.cancel") {
                            isSearchFieldFocused = false
                            searchText = ""
                            self.vm.result = nil
                        }
                    }
                }
                .ignoresSafeArea(.keyboard, edges:.bottom)
            }
        }
        
        func performSearch() {
            isLoading = true
            Task {
                await self.vm.search(q: self.searchText)
                await MainActor.run {
                    isLoading = false
                }
            }
        }
        
        struct Item: View {
            
            var data: Search.Model.Item
            
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
                .border(.gray, width: 1)
            }
        }
    }

}
