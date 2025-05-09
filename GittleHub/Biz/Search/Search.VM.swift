//
//  Search.VM.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/9.
//

import Foundation

extension Search {

    class VM: ObservableObject {

        @Published
        var result: Model?

        func search(q: String) async {
            let temp: Model?
            do {
                temp = try await Model.get(queries: [
                    "q": q
                ])
            } catch {
                temp = nil
            }
            await MainActor.run {
                self.result = temp
            }
        }

    }

}
