//
//  PicsumGalleryUITests.swift
//  PicsumGalleryUITests
//
//  Created by Nekto_Ellez on 07.02.2026.
//

import XCTest

final class PicsumGalleryUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOpenAndCloseSettingsScreen() throws {
        let app = XCUIApplication()
        app.launch()

        let settingsButton = app.buttons["photos.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let settingsScreen = app.otherElements["settings.screen"]
        XCTAssertTrue(settingsScreen.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["settings.doneButton"].exists)
        XCTAssertTrue(app.buttons["settings.cancelButton"].exists)

        app.buttons["settings.cancelButton"].tap()
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
