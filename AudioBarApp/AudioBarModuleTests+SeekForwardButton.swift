import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testSeekForwardButtonEnabledWhenNotAtEnd1() {
        let model = Model.readyToPlay(.init(duration: 1, currentTime: 0.99))
        let view = Module.view(for: model)
        XCTAssertTrue(view.isSeekForwardButtonEnabled)
    }

    func testSeekForwardButtonEnabledWhenNotAtEnd2() {
        let model = Model.readyToPlay(.init(duration: 2, currentTime: 1.99))
        let view = Module.view(for: model)
        XCTAssertTrue(view.isSeekForwardButtonEnabled)
    }

    func testSeekForwardButtonDisabledWhenAtEnd1() {
        let model = Model.readyToPlay(.init(duration: 1, currentTime: 1))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isSeekForwardButtonEnabled)
    }

    func testSeekForwardButtonDisabledWhenAtEnd2() {
        let model = Model.readyToPlay(.init(duration: 2, currentTime: 2))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isSeekForwardButtonEnabled)
    }
    
}
