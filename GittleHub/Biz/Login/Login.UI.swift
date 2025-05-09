//
//  Login.UI.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI

struct LoginEntry: View {

    @EnvironmentObject
    var context: AppContext

    var body: some View {
        GeometryReader { g in
            if g.size.width > g.size.height {
                ZStack {
                    Image("FeedEmptyL")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    if self.$context.user.wrappedValue == nil {
                        HStack {
                            Spacer()
                            VStack {
                                Button(LocalizedStringKey("login.button.title")) {
                                    A.showLoginPage = true
                                }
                                .font(.title)
                                .padding(30)
                                .cornerRadius(6)
                                .background(Color.accentColor)
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                                .shadow(color: .black, radius: 10, x: 3, y: 3)
                                Text("login.slogan")
                                    .font(.title2)
                                    .foregroundColor(.accent)
                            }
                            .padding(.trailing, 30)
                        }
                    }
                }
            } else {
                ZStack {
                    Image("FeedEmptyP")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    if self.$context.user.wrappedValue == nil {
                        VStack {
                            Spacer()
                            Button(LocalizedStringKey("login.button.title")) {
                                A.showLoginPage = true
                            }
                            .font(.title)
                            .padding(30)
                            .cornerRadius(6)
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .opacity(0.8)
                            .shadow(color: .black, radius: 10, x: 3, y: 3)
                            Text("login.slogan")
                                .font(.title2)
                                .foregroundColor(.accent)
                                .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoginEntry()
}
