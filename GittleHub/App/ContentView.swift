//
//  ContentView.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/7.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    
    init() {
        UITabBar.setupAppearance()
    }
    
    @EnvironmentObject
    var loginVM: LoginVM
    
    @EnvironmentObject
    var faceAuth: FaceIDAuthenticator
    
    @EnvironmentObject
    var context: AppContext
    
    var body: some View {
        ZStack {
            TabView {
                Feed.FeedsView()
                    .environmentObject(self.context)
                    .tabItem {
                        Image(systemName: "house.fill")
                            .renderingMode(.template)
                            .foregroundColor(.clear)
                        Text("tab.home")
                    }
                if #available(iOS 15.0, *) {
                    Search.UI()
                        .environmentObject(Search.VM())
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("tab.search")
                        }
                } else {
                    // Fallback on earlier versions
                }
                Projects.UI()
                    .environmentObject(self.context)
                    .tabItem {
                        Image(systemName: "document.on.document")
                        Text("tab.repo")
                    }
                Me.MeView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("tab.me")
                    }
                
            }
            .accessibilityIdentifier("tabview")
            .sheet(isPresented: self.$context.showLoginPage) {
                ZStack {
                    Webview()
                        .interceptBeforeLoad { webview, action in
                            self.loginVM.onUserLogin(view: webview, action: action)
                        }
                        .load(url: self.loginVM.requestURL)
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.context.showLoginPage = false // 关闭 sheet
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accent)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                    if self.loginVM.needsBiometry,
                       self.faceAuth.isAuthenticated == false {
                        Button("login.require.biometry") {
                            self.faceAuth.authenticate()
                        }
                        .font(.title)
                        .padding(30)
                        .cornerRadius(6)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .shadow(color: .black, radius: 10, x: 3, y: 3)
                    }
                }
            }
            .onReceive(self.faceAuth.$isAuthenticated) { value in
                if value == true {
                    Task {
                        self.loginVM.needsBiometry = false
                        await self.loginVM.performUserAutoLogin()
                    }
                }
            }

            if let message = self.context.errorMessage {
                VStack {
                    Text("page.error.title")
                    Text(message)
                    Button("page.error.retry") {
                        self.context.errorMessage = nil
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .font(.title2)
                    .background(Color.accentColor)
                    .foregroundColor(Color.white)
                    .opacity(0.8)
                    .shadow(color: .black, radius: 10, x: 3, y: 3)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
