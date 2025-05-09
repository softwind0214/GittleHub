//
//  Context.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI
import Combine

let A = AppContext.shared

class AppContext: ObservableObject {
    
    static let shared = AppContext()

    @Published
    var showLoginPage: Bool = false

    @Published
    var user: User? {
        didSet {
            self.cache.saveToGroup(self.user, for: .user)
        }
    }

    var token: BearerToken? {
        didSet {
            self.cache.saveToGroup(self.token, for: .token)
        }
    }
    
    @Published
    var errorMessage: String?

    init() {
        self.token = self.cache.loadFromGroup(for: .token)
        let user: User? = self.cache.loadFromGroup(for: .user)
        if let user = user {
            Task {
                await MainActor.run {
                    self.user = user
                }
            }
        }
        if let _ = self.token {
            Task {
                if let user = try? await User.get() {
                    await MainActor.run {
                        self.user = user
                    }
                }
            }
        }
    }

    let cache: Cache = .init()
}

extension Cache.Key {
    static let token = Cache.Key(rawValue: "token")
    static let user = Cache.Key(rawValue: "user")
}
