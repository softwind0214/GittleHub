//
//  Feed.VM.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation

extension Feed {

    class VM: ObservableObject {
        
        @Published
        var data: Model = .init(list: [])
        
        func fetch() async throws {
            let list = try await Model.Event.getList()
            await MainActor.run {
                self.data = .init(list: list)
            }
        }
    }

}
