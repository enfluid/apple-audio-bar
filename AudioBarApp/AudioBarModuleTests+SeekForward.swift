import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testSeekForwardWhenPlaying1() {
        var model = Model.readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 0))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 15)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(15))])
    }

    func testSeekForwardWhenPlaying2() {
        var model = Model.readyToPlay(.init(isPlaying: true, duration: 120, currentTime: 60))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: true, duration: 120, currentTime: 75)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(75))])
    }

    func testSeekForwardWhenPaused1() {
        var model = Model.readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 0))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 15)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(15))])
    }

    func testSeekForwardWhenPaused2() {
        var model = Model.readyToPlay(.init(isPlaying: false, duration: 120, currentTime: 60))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 120, currentTime: 75)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(75))])
    }

    func testSeekForwardOvershootWhenPlaying1() {
        var model = Model.readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 59))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(60)), .player(.pause)])
    }

    func testSeekForwardOvershootWhenPlaying2() {
        var model = Model.readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 58))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(60)), .player(.pause)])
    }

    func testSeekForwardOvershootWhenPaused1() {
        var model = Model.readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 59))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(60))])
    }

    func testSeekForwardOvershootWhenPaused2() {
        var model = Model.readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 58))
        let commands = try! Module.update(for: .seekForward, model: &model)
        XCTAssertEqual(model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        XCTAssertEqual(commands, [.player(.setCurrentTime(60))])
    }

    func testSeekBackWhenNotAllowed1() {
        var model = Model.waitingForURL
        XCTAssertThrowsError(try Module.update(for: .seekBack, model: &model))
    }

    func testSeekBackWhenNotAllowed2() {
        var model = Model.readyToLoadURL(URL.arbitrary)
        XCTAssertThrowsError(try Module.update(for: .seekBack, model: &model))
    }
    
}
