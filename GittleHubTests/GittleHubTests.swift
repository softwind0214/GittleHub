//
//  GittleHubTests.swift
//  GittleHubTests
//
//  Created by Softwind on 2025/5/7.
//

import Testing
@testable import GittleHub

struct GittleHubTests {

    @Test func searchAPI() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let result = try await Search.Model.get(queries: [
            "q": "Example"
        ])
        #expect(result.items[0].id == 22327691)
    }
    
    @Test func groupStore() async throws {
        let key = Cache.Key(rawValue: "testkey")
        A.cache.saveToGroup("abcd", for: key)
        let read: String? = A.cache.loadFromGroup(for: key)
        #expect(read == "abcd")
    }

}
