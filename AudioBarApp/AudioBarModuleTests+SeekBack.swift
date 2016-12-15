import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testSeekBack1() {
        var model = Model.readyToPlay(.init(duration: 60, currentTime: 60))
        let commands = try! Module.update(for: .seekBack, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(duration: 60, currentTime: 60 - 15)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(45))])
    }

    func testSeekBack2() {
        var model = Model.readyToPlay(.init(duration: 60, currentTime: 15))
        let commands = try! Module.update(for: .seekBack, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(duration: 60, currentTime: 0)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(0))])
    }

    func testSeekBackOvershoot1() {
        var model = Model.readyToPlay(.init(duration: 60, currentTime: 1))
        let commands = try! Module.update(for: .seekBack, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(duration: 60, currentTime: 0)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(0))])
    }

    func testSeekBackOvershoot2() {
        var model = Model.readyToPlay(.init(duration: 60, currentTime: 2))
        let commands = try! Module.update(for: .seekBack, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(duration: 60, currentTime: 0)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(0))])
    }

    func testSeekForwardWhenNotAllowed1() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .seekForward, model: &model))
    }

    func testSeekForwardWhenNotAllowed2() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .seekForward, model: &model))
    }
    
}
