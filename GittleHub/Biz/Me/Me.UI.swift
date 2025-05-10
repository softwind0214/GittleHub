//
//  Me.UI.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import WebKit

extension Me {
    struct MeView: View {
        
        @EnvironmentObject
        var context: AppContext
        
        @State
        var showLangAlert: Bool = false
        
        @State
        var showLogoutAlert: Bool = false
        
        var body: some View {
            
            if let user = self.context.user {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .center, spacing: 20) {
                            VStack {
                                WebImage(url: .init(string: self.context.user?.avatar_url ?? ""))
                                    .resizable(resizingMode: .stretch)
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(.circle)
                                    .shadow(radius: 10)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(alignment: .leading) {
                                Text(user.name ?? user.login)
                                    .font(.title3)
                                    .bold()
                                Text("@" + user.login)
                                    .font(.title3)
                                    .foregroundColor(.accent)
                                HStack {
                                    Text("\(user.followers)")
                                        .font(.title3)
                                        .bold()
                                    Text("followers")
                                        .font(.title3)
                                }
                                HStack {
                                    Text("\(user.following)")
                                        .font(.title3)
                                        .bold()
                                    Text("following")
                                        .font(.title3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 16, height: 16)

                            Text(user.email ?? "")
                                .font(.title3)
                                .bold()
                        }

                        Text(user.bio ?? "")
                            .font(.title3)
                            .italic()

                        Button("me.button.switchLang") {
                            self.showLangAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .font(.title2)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .shadow(color: .black, radius: 10, x: 3, y: 3)
                        .alert(isPresented: self.$showLangAlert) {
                            Alert(
                                title: Text("me.switchLang.alert.title"),
                                message: Text("me.switchLang.alert.message"),
                                primaryButton: .default(Text("me.switchLang.alert.confirm")) {
                                    Task {
                                        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                                        await UIApplication.shared.open(settingsUrl)
                                    }
                                },
                                secondaryButton: .cancel(Text("me.switchLang.alert.cancel"))
                            )
                        }
                        
                        Button("me.button.logout") {
                            self.showLogoutAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .font(.title2)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .shadow(color: .black, radius: 10, x: 3, y: 3)
                        .alert(isPresented: self.$showLogoutAlert) {
                            Alert(
                                title: Text("me.logout.alert.title"),
                                message: Text("me.logout.alert.message"),
                                primaryButton: .default(Text("me.logout.alert.confirm")) {
                                    A.token = nil
                                    A.user = nil
                                    Webview.clearCookies()
                                },
                                secondaryButton: .cancel(Text("me.logout.alert.cancel"))
                            )
                        }
                    }
                    .padding(20)
                }
            } else {
                LoginEntry()
                    .environmentObject(self.context)
            }

        }
    }
}
