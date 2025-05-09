//
//  Cache.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation

struct Cache {
    
    let decoder: JSONDecoder = .init()
    let encoder: JSONEncoder = .init()
    
    let gi = "group.com.softwind.test.hsbc"

    func saveToGroup<T: Codable>(_ value: T?, for key: Key) {
        do {
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.gi) {
                let fileURL = containerURL.appendingPathComponent(key.rawValue)
                if let value = value {
                    let data = try self.encoder.encode(value)
                    try data.write(to: fileURL)
                    L.info(module: .cache, "\(key): \(value) has been stored")
                } else {
                    try FileManager.default.removeItem(at: fileURL)
                    L.info(module: .cache, "\(key) has been removed")
                }
            }
        } catch {
            L.error(module: .cache, "\(error)")
        }
    }

    func loadFromGroup<T: Codable>(for key: Key) -> T? {
        do {
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.gi) {
                let fileURL = containerURL.appendingPathComponent(key.rawValue)
                let data = try Data(contentsOf: fileURL)
                let model = try self.decoder.decode(T.self, from: data)
                L.info(module: .cache, "\(key): \(model) has been loaded")
                return model
            } else {
                L.info(module: .cache, "\(key) loads failed")
                return nil
            }
        } catch {
            L.error(module: .cache, "\(error)")
            return nil
        }
    }


    func save<T: Codable>(_ value: T?, for key: Key) {
        do {
            if let value = value {
                let data = try self.encoder.encode(value)
                UserDefaults.standard.set(data, forKey: key.rawValue)
                L.info(module: .cache, "\(key): \(value) has been stored")
            } else {
                UserDefaults.standard.removeObject(forKey: key.rawValue)
                L.info(module: .cache, "\(key) has been removed")
            }
        } catch {
            L.error(module: .cache, "\(error)")
        }
    }
    
    func load<T: Codable>(for key: Key) -> T? {
        do {
            if let data = UserDefaults.standard.data(forKey: key.rawValue) {
                let model = try self.decoder.decode(T.self, from: data)
                L.info(module: .cache, "\(key): \(model) has been loaded")
                return model
            } else {
                L.info(module: .cache, "\(key) loads failed")
                return nil
            }
        } catch {
            L.error(module: .cache, "\(error)")
            return nil
        }
    }

    struct Key: RawRepresentable {
        var rawValue: String
        typealias RawValue = String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension LogCenter.Module {
    static let cache = LogCenter.Module(rawValue: "cache")
}
