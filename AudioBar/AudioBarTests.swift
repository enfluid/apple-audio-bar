import XCTest
import Elm

@testable import AudioBar

class AudioBarTests: XCTestCase, Tests {

    typealias Program = AudioBar

    func fail(_ message: String, file: StaticString, line: Int) {
        XCTFail(message, file: file, line: UInt(line))
    }

    // MARK: Start

    func testDefaultModel() {
        let start = expectStart(with: .init())
        expect(start?.state, .waitingForURL)
    }

    // MARK: Update

    func testPrepareToLoad1() {
        let update = expectUpdate(for: .prepareToLoad(.foo), state: .waitingForURL)
        expect(update?.state, .readyToLoadURL(URL.foo))
    }

    func testPrepareToLoad2() {
        let update = expectUpdate(for: .prepareToLoad(.foo), state: .readyToLoadURL(.bar))
        expect(update?.state, .readyToLoadURL(.foo))
    }

    func testPrepareToLoad3() {
        let update = expectUpdate(for: .prepareToLoad(.foo), state: .waitingForPlayerToBecomeReadyToPlayURL(.bar))
        expect(update?.state, .readyToLoadURL(.foo))
        expect(update?.action, .player(.loadURL(nil)))
    }

    func testPrepareToLoad4() {
        let update = expectUpdate(for: .prepareToLoad(.foo), state: .readyToPlay(.init()))
        expect(update?.state, .readyToLoadURL(URL.foo))
        expect(update?.action, .player(.loadURL(nil)))
    }

    func testPrepareToLoadNil1() {
        let update = expectUpdate(for: .prepareToLoad(nil), state: .waitingForURL)
        expect(update?.state, .waitingForURL)
    }

    func testPrepareToLoadNil2() {
        let update = expectUpdate(for: .prepareToLoad(nil), state: .readyToLoadURL(.foo))
        expect(update?.state, .waitingForURL)
    }

    func testPrepareToLoadNil3() {
        let update = expectUpdate(for: .prepareToLoad(nil), state: .waitingForPlayerToBecomeReadyToPlayURL(.foo))
        expect(update?.state, .waitingForURL)
        expect(update?.action, .player(.loadURL(nil)))
    }

    func testPrepareToLoadNil4() {
        let update = expectUpdate(for: .prepareToLoad(nil), state: .readyToPlay(.init()))
        expect(update?.state, .waitingForURL)
        expect(update?.action, .player(.loadURL(nil)))
    }

    func testPlayerDidBecomeReadyToPlay() {
        let update = expectUpdate(for: .playerDidBecomeReadyToPlay(withDuration: 1), state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.state, .readyToPlay(.init(isPlaying: true, duration: 1, currentTime: nil)))
        expect(update?.action, .player(.play))
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly1() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), state: .waitingForURL)
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly2() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), state: .readyToLoadURL(.arbitrary))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly3() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), state: .readyToPlay(.init()))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReady() {
        let update = expectUpdate(for: .playerDidFailToBecomeReady, state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.state, .readyToLoadURL(.arbitrary))
        expect(update?.action, .showAlert(text: "Unable to load media", button: "OK"))
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly1() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, state: .waitingForURL)
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly2() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, state: .readyToLoadURL(.arbitrary))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly3() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, state: .readyToPlay(.init()))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTime1() {
        let update = expectUpdate(for: .playerDidUpdateCurrentTime(1), state: .readyToPlay(.init(currentTime: 0)))
        expect(update?.state, .readyToPlay(.init(currentTime: 1)))
    }

    func testPlayerDidUpdateCurrentTime2() {
        let update = expectUpdate(for: .playerDidUpdateCurrentTime(2), state: .readyToPlay(.init(currentTime: 1)))
        expect(update?.state, .readyToPlay(.init(currentTime: 2)))
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly1() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), state: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly2() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), state: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly3() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEnd() {
        let update = expectUpdate(for: .playerDidPlayToEnd, state: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 0)))
        expect(update?.state, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
    }

    func testPlayerDidPlayToEndUnexpectedly1() {
        let failure = expectFailure(for: .playerDidPlayToEnd, state: .readyToPlay(.init(isPlaying: false)))
        expect(failure, .notPlaying)
    }

    func testPlayerDidPlayToEndUnexpectedly2() {
        let failure = expectFailure(for: .playerDidPlayToEnd, state: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEndUnexpectedly3() {
        let failure = expectFailure(for: .playerDidPlayToEnd, state: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEndUnexpectedly4() {
        let failure = expectFailure(for: .playerDidPlayToEnd, state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekBackButton1() {
        let update = expectUpdate(for: .userDidTapSeekBackButton, state: .readyToPlay(.init(duration: 60, currentTime: 60)))
        let expectedTime = 60 - AudioBar.State.seekInterval
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: expectedTime)))
        expect(update?.action, .player(.setCurrentTime(expectedTime)))
    }

    func testUserDidTapSeekBackButton2() {
        let update = expectUpdate(for: .userDidTapSeekBackButton, state: .readyToPlay(.init(duration: 60, currentTime: 15)))
        let expectedTime = 15 - AudioBar.State.seekInterval
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: expectedTime)))
        expect(update?.action, .player(.setCurrentTime(expectedTime)))
    }

    func testUserDidTapSeekBackButtonNearBeginning1() {
        let update = expectUpdate(for: .userDidTapSeekBackButton, state: .readyToPlay(.init(duration: 60, currentTime: 1)))
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(update?.action, .player(.setCurrentTime(0)))
    }

    func testUserDidTapSeekBackButtonNearBeginning2() {
        let update = expectUpdate(for: .userDidTapSeekBackButton, state: .readyToPlay(.init(duration: 60, currentTime: 2)))
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(update?.action, .player(.setCurrentTime(0)))
    }

    func testUserDidTapSeekBackButtonUnexpectedly1() {
        let failure = expectFailure(for: .userDidTapSeekBackButton, state: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekBackButtonUnexpectedly2() {
        let failure = expectFailure(for: .userDidTapSeekBackButton, state: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekBackButtonUnexpectedly3() {
        let failure = expectFailure(for: .userDidTapSeekBackButton, state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekForwardButton1() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(duration: 60, currentTime: 0)))
        let expectedTime = 0 + AudioBar.State.seekInterval
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: expectedTime)))
        expect(update?.action, .player(.setCurrentTime(expectedTime)))
    }

    func testUserDidTapSeekForwardButton2() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(duration: 60, currentTime: 1)))
        let expectedTime = 1 + AudioBar.State.seekInterval
        expect(update?.state, .readyToPlay(.init(duration: 60, currentTime: expectedTime)))
        expect(update?.action, .player(.setCurrentTime(expectedTime)))
    }

    func testUserDidTapSeekForwardButtonNearEndWhenPlaying1() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 59)))
        expect(update?.state, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        expect(update?.actions[0], .player(.setCurrentTime(60)))
        expect(update?.actions[1], .player(.pause))
    }

    func testUserDidTapSeekForwardButtonNearEndWhenPlaying2() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 58)))
        expect(update?.state, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        expect(update?.actions[0], .player(.setCurrentTime(60)))
        expect(update?.actions[1], .player(.pause))
    }

    func testUserDidTapSeekForwardButtonNearEndWhenPaused1() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 59)))
        expect(update?.action, .player(.setCurrentTime(60)))
    }

    func testUserDidTapSeekForwardButtonNearEndWhenPaused2() {
        let update = expectUpdate(for: .userDidTapSeekForwardButton, state: .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 58)))
        expect(update?.action, .player(.setCurrentTime(60)))
    }

    func testUserDidTapSeekForwardButtonUnexpectedly1() {
        let failure = expectFailure(for: .userDidTapSeekForwardButton, state: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekForwardButtonUnexpectedly2() {
        let failure = expectFailure(for: .userDidTapSeekForwardButton, state: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapSeekForwardButtonUnexpectedly3() {
        let failure = expectFailure(for: .userDidTapSeekForwardButton, state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapPlayButtonWhenReadyToLoadURL() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPlayButton), state: .readyToLoadURL(.arbitrary))
        expect(update?.state, .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.action, .player(.loadURL(.arbitrary)))
    }

    func testUserDidTapPlayButtonWhenReadyToPlayAndNotPlaying() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPlayButton), state: .readyToPlay(.init(isPlaying: false)))
        expect(update?.state, .readyToPlay(.init(isPlaying: true)))
        expect(update?.action, .player(.play))
    }

    func testUserDidTapPlayButtonWhenWaitingForURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), state: .waitingForURL)
        expect(failure, .noURL)
    }

    func testUserDidTapPlayButtonWhenWaitingForPlayerToBecomeReadyToPlayURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .waitingToBecomeReadyToPlay)
    }

    func testUserDidTapPlayButtonWhenReadyToPlayAndPlaying() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), state: .readyToPlay(.init(isPlaying: true)))
        expect(failure, .playing)
    }

    func testUserDidTapPauseButtonWhenWaitingForPlayerToBecomeReadyToPlayURL() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.state, .readyToLoadURL(.arbitrary))
        expect(update?.action, .player(.loadURL(nil)))
    }

    func testUserDidTapPauseButtonWhenReadyToPlayAndPlaying() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), state: .readyToPlay(.init(isPlaying: true)))
        expect(update?.state, .readyToPlay(.init(isPlaying: false)))
        expect(update?.action, .player(.pause))
    }

    func testUserDidTapPauseButtonWhenWaitingForURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), state: .waitingForURL)
        expect(failure, .noURL)
    }

    func testUserDidTapPauseButtonWhenReadyToLoadURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), state: .readyToLoadURL(.arbitrary))
        expect(failure, .readyToLoadURL)
    }

    func testUserDidTapPauseButtonWhenReadyToPlayAndNotPlaying() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), state: .readyToPlay(.init(isPlaying: false)))
        expect(failure, .notPlaying)
    }

    // MARK: View

    func testViewWhenWaitingForURL() {
        let view = expectView(for: .waitingForURL)
        expect(view?.playPauseButtonEvent, .userDidTapPlayButton)
        expect(view?.isPlayPauseButtonEnabled, false)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, false)
        expect(view?.isPlayCommandEnabled, false)
        expect(view?.isPauseCommandEnabled, false)
        expect(view?.seekInterval, 15)
        expect(view?.playbackDuration, 0)
        expect(view?.elapsedPlaybackTime, 0)
    }

    func testViewWhenReadyToLoad() {
        let view = expectView(for: .readyToLoadURL(.arbitrary))
        expect(view?.playPauseButtonEvent, .userDidTapPlayButton)
        expect(view?.isPlayPauseButtonEnabled, true)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.isPlayCommandEnabled, true)
        expect(view?.isPauseCommandEnabled, false)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, false)
        expect(view?.seekInterval, 15)
        expect(view?.playbackDuration, 0)
        expect(view?.elapsedPlaybackTime, 0)
    }

    func testViewWhenWaitingForPlayer() {
        let view = expectView(for: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(view?.playPauseButtonEvent, .userDidTapPauseButton)
        expect(view?.isPlayPauseButtonEnabled, true)
        expect(view?.isPlayCommandEnabled, false)
        expect(view?.isPauseCommandEnabled, true)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, true)
        expect(view?.seekInterval, 15)
        expect(view?.playbackDuration, 0)
        expect(view?.elapsedPlaybackTime, 0)
    }

    func testPlaybackTime1() {
        let view = expectView(for: .readyToPlay(.init(currentTime: nil)))
        expect(view?.playbackTime, "")
    }

    func testPlaybackTime2() {
        let view = expectView(for: .readyToPlay(.init(duration: 1, currentTime: 0)))
        expect(view?.playbackTime, "-0:01")
    }

    func testPlaybackTime3() {
        let view = expectView(for: .readyToPlay(.init(duration: 61, currentTime: 0)))
        expect(view?.playbackTime, "-1:01")
    }

    func testPlaybackTime4() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 20)))
        expect(view?.playbackTime, "-0:40")
    }

    func testPlaybackDuration1() {
        let view = expectView(for: .readyToPlay(.init(duration: 1)))
        expect(view?.playbackDuration, 1)
    }

    func testPlaybackDuration2() {
        let view = expectView(for: .readyToPlay(.init(duration: 2)))
        expect(view?.playbackDuration, 2)
    }

    func testElapsedPlaybackTime1() {
        let view = expectView(for: .readyToPlay(.init(currentTime: nil)))
        expect(view?.elapsedPlaybackTime, 0)
    }

    func testElapsedPlaybackTime2() {
        let view = expectView(for: .readyToPlay(.init(currentTime: 1)))
        expect(view?.elapsedPlaybackTime, 1)
    }

    func testElapsedPlaybackTime3() {
        let view = expectView(for: .readyToPlay(.init(currentTime: 2)))
        expect(view?.elapsedPlaybackTime, 2)
    }

    func testSeekIntervalWhenReadyToPlay() {
        let view = expectView(for: .readyToPlay(.init()))
        expect(view?.seekInterval, 15)
    }

    func testIsPlayCommandEnabled1() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true)))
        expect(view?.isPlayCommandEnabled, false)
    }

    func testIsPlayCommandEnabled2() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false, duration: 1, currentTime: 0)))
        expect(view?.isPlayCommandEnabled, true)
    }

    func testIsPlayCommandEnabled3() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false, duration: 1, currentTime: 1)))
        expect(view?.isPlayCommandEnabled, false)
    }

    func testIsPauseCommandEnabled1() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false)))
        expect(view?.isPauseCommandEnabled, false)
    }

    func testIsPauseCommandEnabled2() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true, duration: 1, currentTime: 0)))
        expect(view?.isPauseCommandEnabled, true)
    }

    func testIsPauseCommandEnabled3() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true, duration: 1, currentTime: 1)))
        expect(view?.isPauseCommandEnabled, false)
    }

    func testIsLoadingIndicatorVisible1() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, true)
    }

    func testIsLoadingIndicatorVisible2() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, false)
    }

    func testIsLoadingIndicatorVisible3() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, false)
    }

    func testIsLoadingIndicatorVisible4() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, false)
    }

    func testIsSeekBackButtonEnabled1() {
        let view = expectView(for: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekBackButtonEnabled, false)
    }

    func testIsSeekBackButtonEnabled2() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(view?.isSeekBackButtonEnabled, false)
    }

    func testIsSeekBackButtonEnabled3() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 1)))
        expect(view?.isSeekBackButtonEnabled, true)
    }

    func testIsSeekBackButtonEnabled4() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 2)))
        expect(view?.isSeekBackButtonEnabled, true)
    }

    func testIsSeekForwardButtonEnabled1() {
        let view = expectView(for: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekForwardButtonEnabled, false)
    }

    func testIsSeekForwardButtonEnabled2() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 58)))
        expect(view?.isSeekForwardButtonEnabled, true)
    }

    func testIsSeekForwardButtonEnabled3() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 59)))
        expect(view?.isSeekForwardButtonEnabled, true)
    }

    func testIsSeekForwardButtonEnabled4() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 60)))
        expect(view?.isSeekForwardButtonEnabled, false)
    }

    func testPlayPauseButtonMode1() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: false)))
        expect(view?.playPauseButtonEvent, .userDidTapPlayButton)
    }

    func testPlayPauseButtonMode2() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true)))
        expect(view?.playPauseButtonEvent, .userDidTapPauseButton)
    }

    func testIsPlayPauseButtonEnabled1() {
        let view = expectView(for: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isPlayPauseButtonEnabled, true)
    }

    func testIsPlayPauseButtonEnabled2() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 60)))
        expect(view?.isPlayPauseButtonEnabled, false)
    }

    func testIsPlayPauseButtonEnabled3() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 59)))
        expect(view?.isPlayPauseButtonEnabled, true)
    }

    func testIsPlayPauseButtonEnabled4() {
        let view = expectView(for: .readyToPlay(.init(duration: 60, currentTime: 58)))
        expect(view?.isPlayPauseButtonEnabled, true)
    }

}

extension AudioBar.State.ReadyToPlay {
    init(isPlaying: Bool = false, duration: TimeInterval = 60, currentTime: TimeInterval? = nil) {
        self.isPlaying = isPlaying
        self.duration = duration
        self.currentTime = currentTime
    }
}

extension URL {

    static let foo = URL(string: "foo")!
    static let bar = URL(string: "bar")!

    static var arbitrary: URL {
        return URL(string: "foo")!
    }
}
