import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlayerDidPlayToEnd() {
        var model = Model.readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 0))
        let commands = try! Module.update(for: .playerDidPlayToEnd, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        XCTAssertTrue(commands.isEmpty)
    }

    func testPlayerDidPlayToEndUnexpectedly1() {
        var model = Model.readyToPlay(.init(isPlaying: false))
        XCTAssertThrowsError(try Module.update(for: .playerDidPlayToEnd, model: &model))
    }

    func testPlayerDidPlayToEndUnexpectedly2() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .playerDidPlayToEnd, model: &model))
    }

    func testPlayerDidPlayToEndUnexpectedly3() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidPlayToEnd, model: &model))
    }

    func testPlayerDidPlayToEndUnexpectedly4() {
        var model = Model.waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidPlayToEnd, model: &model))
    }
    
}
