//
//  GittleHubUITests.swift
//  GittleHubUITests
//
//  Created by Softwind on 2025/5/7.
//

import XCTest

final class GittleHubUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting-language")
        app.launchArguments.append("zh-Hans") // 简体中文
        app.launch() // 启动应用
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSearch() throws {
        let searchTab = app.buttons["搜索"]
        XCTAssertTrue(searchTab.exists)

        searchTab.tap()
        let input = app.textFields["输入关键词 …"]
        XCTAssertTrue(input.exists)

        input.tap()
        input.typeText("Example")
        if app.keyboards.buttons["搜索"].exists {
            app.keyboards.buttons["搜索"].tap()
        }
        if app.keyboards.buttons["search"].exists {
            app.keyboards.buttons["search"].tap()
        }
        
        let result = app.staticTexts["ui-test-22,327,691"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
    }
}
