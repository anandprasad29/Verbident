//
//  SnapshotTests.swift
//  RunnerUITests
//
//  UI Tests for automated App Store screenshot capture
//

import XCTest

class SnapshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testScreenshots() throws {
        // Wait for app to load
        sleep(2)

        // 1. Dashboard screenshot
        snapshot("01_Dashboard")

        // 2. Navigate to Before Visit via dashboard tile
        let beforeVisitTile = app.staticTexts["Before the Visit"]
        if beforeVisitTile.waitForExistence(timeout: 5) {
            beforeVisitTile.tap()
            sleep(2)
            snapshot("02_BeforeVisit")
        }

        // 3. Navigate back to dashboard via AppBar home button, then to Library
        let homeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'home' OR label CONTAINS 'Home'")).firstMatch
        if homeButton.waitForExistence(timeout: 3) {
            homeButton.tap()
            sleep(1)
        }

        let libraryTile = app.staticTexts["Library"]
        if libraryTile.waitForExistence(timeout: 5) {
            libraryTile.tap()
            sleep(2)
            snapshot("03_Library")
        }

        // 4. Navigate back to dashboard, then to Build Your Own
        if homeButton.waitForExistence(timeout: 3) {
            homeButton.tap()
            sleep(1)
        }

        let buildTile = app.staticTexts["Build Your Own"]
        if buildTile.waitForExistence(timeout: 3) {
            buildTile.tap()
            sleep(2)
            snapshot("04_BuildYourOwn")
        }

        // 5. Return to Dashboard for final screenshot
        if homeButton.waitForExistence(timeout: 3) {
            homeButton.tap()
            sleep(1)
            snapshot("05_DashboardFinal")
        }
    }
}
