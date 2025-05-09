//
//  Projects.VM.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation

extension Projects {
    class VM: ObservableObject {
        
        @Published
        var data: Model = .init(list: [])
        
        func fetch() async throws {
            let list = try await Model.Item.getList()
            await MainActor.run {
                self.data = .init(list: list)
            }
        }
    }
}
