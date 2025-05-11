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
        
        var pages: Set<Int> = .init()
        
        func fetch(index: Int) async throws {
            if index == 1 {
                pages.removeAll()
                pages.insert(1)
            } else if pages.contains(index) {
                return
            }
            let list = try await Model.Item.getList(queries: [
                "page": "\(index)"
            ])
            await MainActor.run {
                let newData: Model
                if index == 1 {
                    newData = .init(list: list)
                } else {
                    pages.insert(index)
                    newData = .init(list: self.data.list + list)
                }
                self.data = newData
            }
        }
    }
}
