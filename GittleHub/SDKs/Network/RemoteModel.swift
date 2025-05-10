//
//  RemoteModel.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/10.
//

import Foundation
import SwiftUI
import Alamofire

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
                        switch response.result {
                        case .success(let result):
                            continuation.resume(returning: result)
                        case .failure(let error):
                            if let data = response.data,
                               let info = try? JSONDecoder().decode(GeneralGHRequest.Error.ServerErrorInfo.self, from: data) {
                                continuation.resume(throwing: GeneralGHRequest.Error.server(info))
                            } else {
                                continuation.resume(throwing: error)
                            }
                        }
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
