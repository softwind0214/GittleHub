//
//  Logger.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import Logging

let L = LogCenter.shared

class LogCenter {

    static let shared = LogCenter()
    private init() {}

    private var loggers: [Module: Logger] = [:]

    func log(module: Module, level: Logger.Level, string: String) {
        if let logger = self.loggers[module] {
            logger.log(level: level, .init(stringLiteral: string))
        } else {
            let logger = Logger(label: module.rawValue)
            self.loggers[module] = logger
            logger.log(level: level, .init(stringLiteral: string))
        }
    }

    func info(module: Module = .misc, _ string: String) {
        self.log(module: module, level: .info, string: string)
    }

    func error(module: Module = .misc, _ string: String) {
        self.log(module: module, level: .error, string: string)
    }

    struct Module: RawRepresentable, Hashable, Codable {
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        var rawValue: String
        typealias RawValue = String
        
        static let misc = Module(rawValue: "misc")
    }
}

let log = Logger(label: "")
