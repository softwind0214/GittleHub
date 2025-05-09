//
//  model.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation

struct BearerToken: Codable, RemoteModel {

    static var host: String = GeneralGHRequest.GHHost
    static var path: String = "/login/oauth/access_token"

    let access_token: String
    let expires_in: Int
    let refresh_token: String
    let refresh_token_expires_in: Int
    let token_type: String
}

struct User: Codable, RemoteModel {
    static var path: String = "/user"
    
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: String
    let gravatar_id: String
    let url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let gists_url: String
    let starred_url: String
    let subscriptions_url: String
    let organizations_url: String
    let repos_url: String
    let events_url: String
    let received_events_url: String
    let type: String
    let user_view_type: String?
    let site_admin: Bool
    let name: String
    let company: String?
    let blog: String
    let location: String?
    let email: String
    let hireable: String?
    let bio: String
    let twitter_username: String?
    let notification_email: String?
    let public_repos: Int
    let public_gists: Int
    let followers: Int
    let following: Int
    let created_at: String
    let updated_at: String
}
