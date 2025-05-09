//
//  Model.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI

extension Feed {
    struct Model: Codable {
        let list: [Event]
    }
}

extension Feed.Model {

    // https://docs.github.com/en/rest/using-the-rest-api/github-event-types?apiVersion=2022-11-28#event-object-common-properties
    struct Event: Codable, RemoteModel, Identifiable {
        
        static var path: String {
            "/users/\(A.user?.login ?? "")/received_events"
        }

        let id: String
        let type: `Type`
        let actor: `Actor`
        let repo: Repo
        let payload: Payload
        let `public`: Bool
        let created_at: String
        
        enum `Type`: String, Hashable, Codable {
            case CommitCommentEvent
            case CreateEvent
            case DeleteEvent
            case ForkEvent
            case GollumEvent
            case IssueCommentEvent
            case IssuesEvent
            case MemberEvent
            case PublicEvent
            case PullRequestEvent
            case PullRequestReviewEvent
            case PullRequestReviewCommentEvent
            case PullRequestReviewThreadEvent
            case PushEvent
            case ReleaseEvent
            case SponsorshipEvent
            case WatchEvent
        }

        struct Actor: Codable {
            let id: Int
            let login: String
            let display_login: String?
            let gravatar_id: String
            let url: String
            let avatar_url: String
            
            var displayName: String {
                self.display_login ?? self.login
            }
        }
        
        struct Repo: Codable {
            let id: Int
            let name: String
            let url: String
        }
        
        struct Payload: Codable {
            
            let data: Action
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let action = try? container.decode([String: String].self) {
                    if action["action"] == "started" {
                        self.data = .startedWatch
                    } else {
                        self.data = .unImplement
                    }
                } else if let actoin = try? container.decode(Forkee.self) {
                    self.data = .fork(actoin)
                } else {
                    self.data = .unImplement
                }
            }

            struct Forkee: Codable {
                let name: String
                let full_name: String
                let owner: Event.Actor
                let description: String
            }

            enum Action: Codable {
                case unImplement
                case startedWatch
                case fork(Forkee)
            }
        }
    }
}
