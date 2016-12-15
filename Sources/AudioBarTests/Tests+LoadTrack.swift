import XCTest
@testable import AudioBar

extension Tests {

    func testLoadTrack() {
        var model = Model.waitingForURL
        let commands = try! Module.update(for: .prepareToLoad(URL.arbitrary), model: &model)
        XCTAssertEqual(model, .readyToLoadURL(URL.arbitrary))
        XCTAssertTrue(commands.isEmpty)
    }

    // TODO: How do we handle this?
    func testLoadTrackUnexpectedly() {}

}
