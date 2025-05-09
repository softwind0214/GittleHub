//
//  Search.Model.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation
import SwiftUI

extension Search {

    struct Model: Codable, RemoteModel {

        static var path: String = "/search/repositories"
        
        let total_count: Int
        let incomplete_results: Bool
        let items: [Item]
        
        struct Item: Codable, Identifiable {
            let id: Int
            let name: String
            let full_name: String
            let owner: Owner
            let html_url: String
            let description: String?
            let updated_at: String
            let stargazers_count: Int
            let language: String?
            
            struct Owner: Codable {
                let id: Int
                let login: String
                let avatar_url: String
                let html_url: String
                let type: String
            }
        }
    }
}
