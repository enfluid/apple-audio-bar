import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlaybackTimeEmptyWhenCurrentTimeIsMissing() {
        let model = Model.readyToPlay(.init(currentTime: nil))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playbackTime, "")
    }

    func testPlaybackTimeWhenAtBeginning1() {
        let model = Model.readyToPlay(.init(duration: 1, currentTime: 0))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playbackTime, "-0:01")
    }

    func testPlaybackTimeWhenAtBeginning2() {
        let model = Model.readyToPlay(.init(duration: 61, currentTime: 0))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playbackTime, "-1:01")
    }

    func testPlaybackTimeWhenPastBeginning() {
        let model = Model.readyToPlay(.init(duration: 60, currentTime: 20))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playbackTime, "-0:40")
    }
    
}
