import XCTest
@testable import AudioBarApp

//
// MARK: -
// MARK: Test case
//

final class AudioBarModuleTests: XCTestCase {}

//
// MARK: -
// MARK: Aliases
//

typealias Module = AudioBarModule

typealias Model = Module.Model
typealias View = Module.View
typealias Command = Module.Command

//
// MARK: -
// MARK: Default initializers
//

extension Model.ReadyState {

    init(isPlaying: Bool = false, duration: TimeInterval = 60, currentTime: TimeInterval? = nil) {
        self.isPlaying = isPlaying
        self.duration = duration
        self.currentTime = currentTime
    }

}

//
// MARK: -
// MARK: Equatable conformances
//

extension View: Equatable {
    public static func ==(lhs: View, rhs: View) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

extension Command: Equatable {
    public static func ==(lhs: Command, rhs: Command) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

extension Model: Equatable {
    public static func ==(lhs: Model, rhs: Model) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

//
// MARK: -
// MARK: Utilities
//

extension URL {

    static var arbitrary: URL {
        return URL(string: "foo")!
    }
    
}
