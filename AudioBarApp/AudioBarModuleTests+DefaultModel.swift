import XCTest
@testable import AudioBarApp

extension AudioBarModuleTests {

    func testDefaultModel() {
        let model = Model()
        XCTAssertEqual(model, .waitingForURL)
    }

}
