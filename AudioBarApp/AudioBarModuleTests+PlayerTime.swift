import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlayerDidUpdateCurrentTime1() {
        var model = Model.readyToPlay(.init(currentTime: 0))
        let commands = try! Module.update(for: .playerDidUpdateCurrentTime(1), model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(currentTime: 1)))
        XCTAssertTrue(commands.isEmpty)
    }

    func testPlayerDidUpdateCurrentTime2() {
        var model = Model.readyToPlay(.init(currentTime: 1))
        let commands = try! Module.update(for: .playerDidUpdateCurrentTime(2), model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(currentTime: 2)))
        XCTAssertTrue(commands.isEmpty)
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly1() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .playerDidUpdateCurrentTime(0), model: &model))
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly2() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidUpdateCurrentTime(0), model: &model))
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly3() {
        var model = Model.waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidUpdateCurrentTime(0), model: &model))
    }

}
