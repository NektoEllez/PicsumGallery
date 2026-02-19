import XCTest

final class PicsumGalleryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }

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
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
