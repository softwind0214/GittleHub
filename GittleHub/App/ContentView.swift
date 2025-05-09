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
    
    var listener = NetworkReachabilityManager()
    
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
                        .interceptWhenFail { webview, nav, error in
                            self.context.showLoginPage = false
                            self.listener?.startListening { status in
                                switch status {
                                case .notReachable, .unknown:
                                    break
                                default:
                                    self.context.showLoginPage = true
                                    self.listener?.stopListening()
                                }
                            }
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
                        await self.loginVM.performUserAutoLogin()
                    }
                }
            }

            if let message = self.context.errorMessage {
                VStack(alignment: .leading, spacing: 40) {
                    Text("page.error.title")
                        .font(.title)
                        .foregroundColor(Color.black)
                        .bold()
                        .padding(.top, 20)
                    Text(message)
                        .font(.title3)
                        .foregroundColor(Color.black)
                    Color.clear
                        .frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                        Button("page.error.retry") {
                            self.context.errorMessage = nil
                        }
                        .font(.title)
                        .padding(.init(top: 20, leading: 40, bottom: 20, trailing: 40))
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .shadow(color: .black, radius: 10, x: 3, y: 3)
                        .frame(alignment: .center)
                        Spacer()
                    }

                    Spacer()
                }
                .padding(20)
                .background(Color.white)                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
