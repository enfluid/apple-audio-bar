import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testPlayPauseButtonModeWhenPaused() {
        let model = Model.readyToPlay(.init(isPlaying: false))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playPauseButtonMode, .play)
    }

    func testPlayPauseButtonModeWhenPlaying() {
        let model = Model.readyToPlay(.init(isPlaying: true))
        let view = Module.view(for: model)
        XCTAssertEqual(view.playPauseButtonMode, .pause)
    }

    func testPlayPauseEnabled() {
        let model = Model.readyToPlay(.init(duration: 60, currentTime: 59))
        let view = Module.view(for: model)
        XCTAssertTrue(view.isPlayPauseButtonEnabled)
    }

    func testPlayButtonDisabledWhenNoTimeRemaining() {
        let model = Model.readyToPlay(.init(duration: 60, currentTime: 60))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isPlayPauseButtonEnabled)
    }
    
}
