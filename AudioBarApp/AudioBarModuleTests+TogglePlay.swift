import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testTogglePlayWhenReadyToLoad() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        let commands = try! Module.update(for: .togglePlay, model: &model)
        XCTAssertEqual(model, .waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary))
        XCTAssertEqual(commands, [.player(.loadURL(URL.arbitrary))])
    }

    func testTogglePlayWhenPlaying() {
        var model = Model.readyToPlay(.init(isPlaying: true))
        let commands = try! Module.update(for: .togglePlay, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false)))
        XCTAssertEqual(commands, [.player(.pause)])
    }

    func testTogglePlayWhenPaused() {
        var model = Model.readyToPlay(.init(isPlaying: false))
        let commands = try! Module.update(for: .togglePlay, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: true)))
        XCTAssertEqual(commands, [.player(.play)])
    }

    func testTogglePlayUnexpectedly() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .togglePlay, model: &model))
    }

    func testTogglePlayWhenWaitingForPlayerToBecomeReadyToPlayURL() {
        var model = Model.waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary)
        let commands = try! Module.update(for: .togglePlay, model: &model)
        XCTAssertEqual(model, .readyToLoadURL(URL.arbitrary))
        XCTAssertEqual(commands, [.player(.reset)])
    }

}
