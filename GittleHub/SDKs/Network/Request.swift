//
//  Request.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import Alamofire

protocol GHRequest {

    func url(_ value: String) -> Self
    func scheme(_ value: String) -> Self
    func host(_ value: String) -> Self
    func path(_ value: String) -> Self
    func query(key: String, value: String) -> Self
    func header(key: String, value: String) -> Self
    func method(_ value: HTTPMethod) -> Self

    func bodyAppend(key: String, value: String) -> Self
    func bodySet(value: any Encodable) -> Self
    func body(_ type: GHRequestBodyType) -> Self
    
    func build() throws -> Alamofire.DataRequest

    static func anInstance() -> Self
}

enum GHRequestBodyType {
    case json
    case form
}

class GeneralGHRequest: GHRequest {
    
    var method: HTTPMethod = .get
    var type: GHRequestBodyType = .json
    var scheme: String = ""
    var host: String = ""
    var path: String = ""
    var query: [String: String] = [:]
    var header: [String: String] = [:]

    var dicBody: [String: String] = [:]
    var modelBody: (any Encodable)?

    func url(_ value: String) -> Self {
        if let url = URL(string: value),
           let uc = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let scheme = uc.scheme {
                self.scheme = scheme
            }
            if let host = uc.host {
                self.host = host
            }
            self.path = uc.path
            for item in uc.queryItems ?? [] {
                if let iv = item.value {
                    self.query[item.name] = iv
                }
            }
        }
        return self
    }
    
    func scheme(_ value: String) -> Self {
        self.scheme = value
        return self
    }
    
    func host(_ value: String) -> Self {
        self.host = value
        return self
    }
    
    func path(_ value: String) -> Self {
        self.path = value
        return self
    }
    
    func query(key: String, value: String) -> Self {
        self.query[key] = value
        return self
    }
    
    func header(key: String, value: String) -> Self {
        self.header[key] = value
        return self
    }
    
    func method(_ value: HTTPMethod) -> Self {
        self.method = value
        return self
    }
    
    func bodyAppend(key: String, value: String) -> Self {
        self.dicBody[key] = value
        return self
    }

    func bodySet(value: any Encodable) -> Self {
        self.modelBody = value
        return self
    }

    func body(_ type: GHRequestBodyType) -> Self {
        self.type = type
        return self
    }

    func build() throws -> Alamofire.DataRequest {

        if !self.path.isEmpty,
           self.path.first != "/" {
            self.path = "/" + self.path
        }
        let urlString = "\(self.scheme)://\(self.host)\(self.path)"
        guard var uc = URLComponents(string: urlString) else {
            throw Error.invalidURL
        }
        uc.queryItems = self.query.isEmpty ? nil : self.query.map { .init(name: $0.key, value: $0.value) }
        guard let url = uc.url else {
            throw Error.invalidURL
        }
        var request = URLRequest(url: url)
        request.method = self.method
        
        self.header["Accept"] = "application/vnd.github.v3+json"
        if let token = A.token {
            self.header["Authorization"] = "Bearer \(token.access_token)"
        }
        let afh = HTTPHeaders(self.header.map { .init(name: $0.key, value: $0.value) })

        switch type {
        case .json:
            if let model = self.modelBody {
                return AF.request(
                    url,
                    method: self.method,
                    parameters: model,
                    encoder: JSONParameterEncoder.default,
                    headers: afh
                )
            } else {
                return AF.request(
                    url,
                    method: self.method,
                    parameters: self.dicBody.isEmpty ? nil : self.dicBody,
                    encoder: JSONParameterEncoder.default,
                    headers: afh
                )
            }
        case .form:
            if let model = self.modelBody {
                return AF.request(
                    url,
                    method: self.method,
                    parameters: model,
                    encoder: URLEncodedFormParameterEncoder.default,
                    headers: afh
                )
            } else {
                return AF.request(
                    url,
                    method: self.method,
                    parameters: self.dicBody.isEmpty ? nil : self.dicBody,
                    encoder: URLEncodedFormParameterEncoder.default,
                    headers: afh
                )
            }
        }
    }
    
    required init() {}
    
    static func anInstance() -> Self {
        Self()
            .scheme(GHScheme)
            .host(GHAPIHost)
    }

    enum Error: LocalizedError {
        case invalidURL
        var errorDescription: String? {
            "GeneralGHRequest.Error.invalidURL"
        }
    }
}

extension GeneralGHRequest {
    
    static let GHScheme = "https"
    static let GHHost = "github.com"
    static let GHAPIHost = "api.github.com"

}

protocol RemoteModel {

    static var host: String { get }
    static var path: String { get }

    static func buildRequest(method: HTTPMethod, body: GHRequestBodyType, params: [String: String], queries: [String: String]) -> GHRequest
}

extension RemoteModel {
    
    static var host: String {
        GeneralGHRequest.GHAPIHost
    }

    static func buildRequest(method: HTTPMethod, body: GHRequestBodyType, params: [String: String], queries: [String: String]) -> GHRequest {
        let request = GeneralGHRequest
            .anInstance()
            .method(method)
            .body(body)
            .host(self.host)
            .path(self.path)
        params.forEach { item in
            _ = request.bodyAppend(key: item.key, value: item.value)
        }
        queries.forEach { item in
            _ = request.query(key: item.key, value: item.value)
        }
        return request
    }

}

extension RemoteModel where Self: Decodable {
    
    static func request(method: HTTPMethod, body: GHRequestBodyType, params: [String: String] = [:], queries: [String: String] = [:]) async throws -> Self {
        let request = self.buildRequest(method: method, body: body, params: params, queries: queries)
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try request
                    .build()
                    .responseDecodable(of: Self.self) { response in
                        L.info(module: .network, response.debugDescription)
                        continuation.resume(with: response.result)
                    }
                    .resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    static func requestList(method: HTTPMethod, body: GHRequestBodyType, params: [String: String] = [:], queries: [String: String] = [:]) async throws -> [Self] {
        let request = self.buildRequest(method: method, body: body, params: params, queries: queries)
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try request
                    .build()
                    .responseDecodable(of: [Self].self) { response in
                        L.info(module: .network, response.debugDescription)
                        continuation.resume(with: response.result)
                    }
                    .resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    static func get(params: [String: String] = [:], queries: [String: String] = [:]) async throws -> Self {
        try await self.request(method: .get, body: .json, params: params, queries: queries)
    }

    static func getList(params: [String: String] = [:], queries: [String: String] = [:]) async throws -> [Self] {
        try await self.requestList(method: .get, body: .json, params: params, queries: queries)
    }

    static func post(params: [String: String] = [:], queries: [String: String] = [:]) async throws -> Self {
        try await self.request(method: .post, body: .json, params: params, queries: queries)
    }
    
    static func form(params: [String: String] = [:], queries: [String: String] = [:]) async throws -> Self {
        try await self.request(method: .post, body: .form, params: params, queries: queries)
    }
}

extension LogCenter.Module {
    static let network = LogCenter.Module(rawValue: "network")
}
