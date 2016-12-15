import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlayerDidBecomeReadyToPlay() {
        var model = Model.waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary)
        let commands = try! Module.update(for: .playerDidBecomeReadyToPlay(withDuration: 1), model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: true, duration: 1, currentTime: nil)))
        XCTAssertEqual(commands, [.player(.play)])
    }

    func testPlayerdidBecomeReadyToPlayUnexpectedly1() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: &model))
    }

    func testPlayerdidBecomeReadyToPlayUnexpectedly2() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: &model))
    }

    func testPlayerdidBecomeReadyToPlayUnexpectedly3() {
        var model = Model.readyToPlay(.init())
        XCTAssertThrowsError(try Module.update(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: &model))
    }
    
}
