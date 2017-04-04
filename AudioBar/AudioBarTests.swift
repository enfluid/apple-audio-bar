import XCTest
import Stateful

@testable import AudioBar

class AudioBarTests: XCTestCase, StateMachineTests {

    typealias StateMachine = AudioBar

    func fail(_ message: String, file: StaticString, line: Int) {
        XCTFail(message, file: file, line: UInt(line))
    }

    func testInitialState() {
        expect(AudioBar.initialState, equals: .waitingForURL)
    }

    // MARK: - Ready to play

    // MARK: + Player did update current time

    func test_ReadyToPlay_PlayerDidUpdateCurrentTime_Event1() {
        let state = expectState(for: .didReceive(.playerDidUpdateCurrentTime(1)), state: .readyToPlay(.init(currentTime: 0)))
        expect(state, equals: .readyToPlay(.init(currentTime: 1)))
    }

    func test_ReadyToPlay_PlayerDidUpdateCurrentTime_Event2() {
        let state = expectState(for: .didReceive(.playerDidUpdateCurrentTime(2)), state: .readyToPlay(.init(currentTime: 1)))
        expect(state, equals: .readyToPlay(.init(currentTime: 2)))
    }

    func test_ReadyToPlay_PlayerDidUpdateCurrentTime_Event3() {
        let state = expectState(for: .didReceive(.playerDidPlayToEnd), state: .readyToPlay(.init(isPlaying: true, currentTime: 0, info: .init(duration: 60))))
        expect(state, equals: .readyToPlay(.init(isPlaying: false, currentTime: 60, info: .init(duration: 60))))
    }

    // MARK: + User did tap play/pause button

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Event1() {
        let action = expectAction(for: .didReceive(.userDidTapPlayPauseButton), state: .readyToPlay(.init(isPlaying: true)))
        expect(action, equals: .player(.pause))
    }

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Event2() {
        let action = expectAction(for: .didReceive(.userDidTapPlayPauseButton), state: .readyToPlay(.init(isPlaying: false)))
        expect(action, equals: .player(.play))
    }

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Event3() {
        let action = expectAction(for: .didReceive(.userDidTapPlayButton), state: .readyToPlay(.init(isPlaying: false)))
        expect(action, equals: .player(.play))
    }

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Event4() {
        let action = expectAction(for: .didReceive(.userDidTapPauseButton), state: .readyToPlay(.init(isPlaying: true)))
        expect(action, equals: .player(.pause))
    }

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Action1() {
        let state = expectState(for: .didPerform(.player(.play), result: Void()), state: .readyToPlay(.init(isPlaying: false)))
        expect(state, equals: .readyToPlay(.init(isPlaying: true)))
    }

    func test_ReadyToPlay_UserDidTapPlayPauseButton_Action2() {
        let state = expectState(for: .didPerform(.player(.pause), result: Void()), state: .readyToPlay(.init(isPlaying: true)))
        expect(state, equals: .readyToPlay(.init(isPlaying: false)))
    }

    // MARK: + User did tap seek back/forward button

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event1() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: 60)))
        expect(action, equals: .player(.setCurrentTime(60 - AudioBar.State.seekInterval)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event2() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: 120)))
        expect(action, equals: .player(.setCurrentTime(120 - AudioBar.State.seekInterval)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event3() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: AudioBar.State.seekInterval - 1)))
        expect(action, equals: .player(.setCurrentTime(0)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event4() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: AudioBar.State.seekInterval - 2)))
        expect(action, equals: .player(.setCurrentTime(0)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event5() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(0 + AudioBar.State.seekInterval)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event6() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 1, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(1 + AudioBar.State.seekInterval)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event7() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 60 - 1, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(60)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Event8() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 60 - 2, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(60)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Action1() {
        let state = expectState(for: .didPerform(.player(.setCurrentTime(60)), result: Void()), state: .readyToPlay(.init(currentTime: nil)))
        expect(state, equals: .readyToPlay(.init(currentTime: 60)))
    }

    func test_ReadyToPlay_UserDidTapSeekBackForwardButton_Action2() {
        let state = expectState(for: .didPerform(.player(.setCurrentTime(120)), result: Void()), state: .readyToPlay(.init(currentTime: 60)))
        expect(state, equals: .readyToPlay(.init(currentTime: 120)))
    }

    // MARK: + Reset

    func test_ReadyToPlay_Reset_Event() {
        let action = expectAction(for: .didReceive(.reset), state: .readyToPlay(.init()))
        expect(action, equals: .player(.load(nil)))
    }

    func test_ReadyToPlay_Reset_Action() {
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .readyToPlay(.init()))
        expect(state, equals: .waitingForURL)
    }

}

extension AudioBar.State.ReadyToPlay {
    init(
        isPlaying: Bool = false,
        currentTime: TimeInterval? = nil,
        info: AudioBar.Action.Player.Info = .init()
        ) {
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.info = info
    }
}

extension URL {

    static let foo = URL(string: "foo")!
    static let bar = URL(string: "bar")!

    static var arbitrary: URL {
        return URL(string: "foo")!
    }
}

extension TimeInterval {
    static let foo: TimeInterval = 1
    static let bar: TimeInterval = 1
}

extension AudioBar.Action.Player.Info {
    init(
        title: String? = "title",
        artist: String? = "artist",
        album: String? = "album",
        artwork: Data? = nil,
        duration: TimeInterval = 1
        ) {
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.duration = duration
    }
}
