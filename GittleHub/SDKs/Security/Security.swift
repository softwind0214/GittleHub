//
//  Security.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import CryptoSwift

enum Security {
    
    static let nicai = "softwindsoftwind"

    static func encrypt(_ string: String) throws -> String {
        let aes = try AES(key: nicai, iv: .init(nicai.reversed())) // aes128
        let ciphertext = try aes.encrypt(Array(string.utf8))
        return ciphertext.toHexString()
    }

    static func decrypt(_ string: String) throws -> String {
        let aes = try AES(key: nicai, iv: .init(nicai.reversed())) // aes128
        let ciphertext = try aes.decrypt(Array(hex: string))
        return .init(data: .init(ciphertext), encoding: .utf8)!
    }

    @propertyWrapper
    struct Encrypted {

        var wrappedValue: String
        let encryptedValue: String

        init(wrappedValue: String) {
            self.encryptedValue = wrappedValue
            self.wrappedValue = try! Security.decrypt(self.encryptedValue)
        }

        var projectedValue: Encrypted {
            self
        }
    }
}
