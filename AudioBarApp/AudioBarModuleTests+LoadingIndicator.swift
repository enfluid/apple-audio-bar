import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testLoadingIndicatorHiddenWhenPausedWithCurrentTimeAvailable() {
        let model = Model.readyToPlay(.init(isPlaying: false, currentTime: 0))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isLoadingIndicatorVisible)
    }

    func testLoadingIndicatorHiddenWhenPausedWithNoCurrentTime() {
        let model = Model.readyToPlay(.init(isPlaying: false, currentTime: nil))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isLoadingIndicatorVisible)
    }

    func testLoadingIndicatorHiddenWhenPlayingWithCurrentTimeAvailable() {
        let model = Model.readyToPlay(.init(isPlaying: true, currentTime: 0))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isLoadingIndicatorVisible)
    }

    func testLoadingIndicatorVisibleWhenPlayingWithNoCurrentTime() {
        let model = Model.readyToPlay(.init(isPlaying: true, currentTime: nil))
        let view = Module.view(for: model)
        XCTAssertTrue(view.isLoadingIndicatorVisible)
    }
    
}
