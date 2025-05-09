//
//  Projects.Model.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation

extension Projects {
    struct Model: Codable {
        let list: [Item]
        struct Item: Codable, Identifiable, RemoteModel {
            static var path: String = "/user/repos"
            let id: Int
            let full_name: String
            let language: String?
            let `private`: Bool
            let description: String?
            let html_url: String
            let fork: Bool
            let stargazers_count: Int
            let updated_at: String
            let owner: Search.Model.Item.Owner
        }
    }
}
