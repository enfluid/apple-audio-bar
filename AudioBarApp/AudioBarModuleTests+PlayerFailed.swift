import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlayerDidFailToBecomeReady() {
        var model = Model.waitingForPlayerToBecomeReadyToPlayURL(URL.arbitrary)
        let commands = try! Module.update(for: .playerDidFailToBecomeReady, model: &model)
        XCTAssertEqual(model, .readyToLoadURL(URL.arbitrary))
        XCTAssertEqual(commands, [.player(.reset), .showAlert(title: "Error", text: "Unable to load media")])
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly1() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .playerDidFailToBecomeReady, model: &model))
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly2() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .playerDidFailToBecomeReady, model: &model))
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly3() {
        var model = Model.readyToPlay(.init())
        XCTAssertThrowsError(try Module.update(for: .playerDidFailToBecomeReady, model: &model))
    }
    
}
