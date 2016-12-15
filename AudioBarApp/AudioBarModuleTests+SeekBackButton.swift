import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testSeekBackButtonEnabled1() {
        let model = Model.readyToPlay(.init(duration: 60, currentTime: 0))
        let view = Module.view(for: model)
        XCTAssertFalse(view.isSeekBackButtonEnabled)
    }

    func testSeekBackButtonEnabled2() {
        let model = Model.readyToPlay(.init(duration: 60, currentTime: 0.01))
        let view = Module.view(for: model)
        XCTAssertTrue(view.isSeekBackButtonEnabled)
    }
    
}
