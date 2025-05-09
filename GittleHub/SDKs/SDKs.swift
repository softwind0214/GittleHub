//
//  SDKs.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/7.
//

import Foundation
import FMDB

// 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


// client_secret: 4c7b2ff0768f78d6c9174d6cd00e615d4b816f0e

let S = GHSDK()

class GHSDK {
    let c: Context = .init()
    class Context: ObservableObject {
        
        @Published
        var showLoginPage: Bool = false
    }
}
