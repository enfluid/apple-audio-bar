import XCTest
@testable import AudioBar

typealias Module = AudioBarModule

public typealias Model = Module.Model
public typealias Command = Module.Command
public typealias View = Module.View

extension Model.ReadyState {
    init(isPlaying: Bool = false, duration: TimeInterval = 60, currentTime: TimeInterval? = nil) {
        self.isPlaying = isPlaying
        self.duration = duration
        self.currentTime = currentTime
    }
}

extension Model: Equatable {
    public static func ==(lhs: Model, rhs: Model) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

extension Command: Equatable {
    public static func ==(lhs: Command, rhs: Command) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

extension View: Equatable {
    public static func ==(lhs: View, rhs: View) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

extension URL {
    static var arbitrary: URL {
        return URL(string: "foo")!
    }
}
