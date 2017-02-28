import XCTest
import Elm

@testable import AudioBar

class AudioBarTests: XCTestCase, Tests {

    typealias Module = AudioBar
    let failureReporter = XCTFail

    // MARK: Start

    func testDefaultModel() {
        let start = expectStart(with: .init())
        expect(start?.model, .waitingForURL)
    }

    // MARK: Update

    func testPrepareToLoad1() {
        let update = expectUpdate(for: .prepareToLoad(URL.foo), model: .waitingForURL)
        expect(update?.model, .readyToLoadURL(URL.foo))
    }

    func testPrepareToLoad2() {
        let update = expectUpdate(for: .prepareToLoad(URL.foo), model: .readyToLoadURL(URL.bar))
        expect(update?.model, .readyToLoadURL(URL.foo))
    }

    func testPrepareToLoad3() {
        let update = expectUpdate(for: .prepareToLoad(URL.foo), model: .waitingForPlayerToBecomeReadyToPlayURL(URL.bar))
        expect(update?.model, .readyToLoadURL(URL.foo))
        expect(update?.command, .player(.loadURL(nil)))
    }

    func testPrepareToLoad4() {
        let update = expectUpdate(for: .prepareToLoad(URL.foo), model: .readyToPlay(.init()))
        expect(update?.model, .readyToLoadURL(URL.foo))
        expect(update?.command, .player(.loadURL(nil)))
    }

    func testPrepareToLoadNil1() {
        let update = expectUpdate(for: .prepareToLoad(nil), model: .waitingForURL)
        expect(update?.model, .waitingForURL)
    }

    func testPrepareToLoadNil2() {
        let update = expectUpdate(for: .prepareToLoad(nil), model: .readyToLoadURL(URL.foo))
        expect(update?.model, .waitingForURL)
    }

    func testPrepareToLoadNil3() {
        let update = expectUpdate(for: .prepareToLoad(nil), model: .waitingForPlayerToBecomeReadyToPlayURL(URL.foo))
        expect(update?.model, .waitingForURL)
        expect(update?.command, .player(.loadURL(nil)))
    }

    func testPrepareToLoadNil4() {
        let update = expectUpdate(for: .prepareToLoad(nil), model: .readyToPlay(.init()))
        expect(update?.model, .waitingForURL)
        expect(update?.command, .player(.loadURL(nil)))
    }

    func testPlayerDidBecomeReadyToPlay() {
        let update = expectUpdate(for: .playerDidBecomeReadyToPlay(withDuration: 1), model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.model, .readyToPlay(.init(isPlaying: true, duration: 1, currentTime: nil)))
        expect(update?.command, .player(.play))
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly1() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: .waitingForURL)
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly2() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: .readyToLoadURL(.arbitrary))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidBecomeReadyToPlayUnexpectedly3() {
        let failure = expectFailure(for: .playerDidBecomeReadyToPlay(withDuration: 0), model: .readyToPlay(.init()))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReady() {
        let update = expectUpdate(for: .playerDidFailToBecomeReady, model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.model, .readyToLoadURL(.arbitrary))
        expect(update?.command, .showAlert(text: "Unable to load media", button: "OK"))
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly1() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, model: .waitingForURL)
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly2() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, model: .readyToLoadURL(.arbitrary))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidFailToBecomeReadyUnexpectedly3() {
        let failure = expectFailure(for: .playerDidFailToBecomeReady, model: .readyToPlay(.init()))
        expect(failure, .notWaitingToBecomeReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTime1() {
        let update = expectUpdate(for: .playerDidUpdateCurrentTime(1), model: .readyToPlay(.init(currentTime: 0)))
        expect(update?.model, .readyToPlay(.init(currentTime: 1)))
    }

    func testPlayerDidUpdateCurrentTime2() {
        let update = expectUpdate(for: .playerDidUpdateCurrentTime(2), model: .readyToPlay(.init(currentTime: 1)))
        expect(update?.model, .readyToPlay(.init(currentTime: 2)))
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly1() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), model: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly2() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), model: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidUpdateCurrentTimeUnexpectedly3() {
        let failure = expectFailure(for: .playerDidUpdateCurrentTime(0), model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEnd() {
        let update = expectUpdate(for: .playerDidPlayToEnd, model: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 0)))
        expect(update?.model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
    }

    func testPlayerDidPlayToEndUnexpectedly1() {
        let failure = expectFailure(for: .playerDidPlayToEnd, model: .readyToPlay(.init(isPlaying: false)))
        expect(failure, .notPlaying)
    }

    func testPlayerDidPlayToEndUnexpectedly2() {
        let failure = expectFailure(for: .playerDidPlayToEnd, model: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEndUnexpectedly3() {
        let failure = expectFailure(for: .playerDidPlayToEnd, model: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testPlayerDidPlayToEndUnexpectedly4() {
        let failure = expectFailure(for: .playerDidPlayToEnd, model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testSeekBack1() {
        let update = expectUpdate(for: .seekBack, model: .readyToPlay(.init(duration: 60, currentTime: 60)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 60 - AudioBar.Model.seekInterval)))
        expect(update?.command, .player(.setCurrentTime(60 - AudioBar.Model.seekInterval)))
    }

    func testSeekBack2() {
        let update = expectUpdate(for: .seekBack, model: .readyToPlay(.init(duration: 60, currentTime: 15)))
        expect(update?.command, .player(.setCurrentTime(15 - AudioBar.Model.seekInterval)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 15 - AudioBar.Model.seekInterval)))
    }

    func testSeekBackNearBeginning1() {
        let update = expectUpdate(for: .seekBack, model: .readyToPlay(.init(duration: 60, currentTime: 1)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(update?.command, .player(.setCurrentTime(0)))
    }

    func testSeekBackNearBeginning2() {
        let update = expectUpdate(for: .seekBack, model: .readyToPlay(.init(duration: 60, currentTime: 2)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(update?.command, .player(.setCurrentTime(0)))
    }

    func testSeekBackUnexpectedly1() {
        let failure = expectFailure(for: .seekBack, model: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testSeekBackUnexpectedly2() {
        let failure = expectFailure(for: .seekBack, model: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testSeekBackUnexpectedly3() {
        let failure = expectFailure(for: .seekBack, model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testSeekForward1() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(duration: 60, currentTime: 0)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 0 + AudioBar.Model.seekInterval)))
        expect(update?.command, .player(.setCurrentTime(0 + AudioBar.Model.seekInterval)))
    }

    func testSeekForward2() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(duration: 60, currentTime: 1)))
        expect(update?.model, .readyToPlay(.init(duration: 60, currentTime: 1 + AudioBar.Model.seekInterval)))
        expect(update?.command, .player(.setCurrentTime(1 + AudioBar.Model.seekInterval)))
    }

    func testSeekForwardNearEndWhenPlaying1() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 59)))
        expect(update?.model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        expect(update?.commands[0], .player(.setCurrentTime(60)))
        expect(update?.commands[1], .player(.pause))
    }

    func testSeekForwardNearEndWhenPlaying2() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(isPlaying: true, duration: 60, currentTime: 58)))
        expect(update?.model, .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 60)))
        expect(update?.commands[0], .player(.setCurrentTime(60)))
        expect(update?.commands[1], .player(.pause))
    }

    func testSeekForwardNearEndWhenPaused1() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 59)))
        expect(update?.command, .player(.setCurrentTime(60)))
    }

    func testSeekForwardNearEndWhenPaused2() {
        let update = expectUpdate(for: .seekForward, model: .readyToPlay(.init(isPlaying: false, duration: 60, currentTime: 58)))
        expect(update?.command, .player(.setCurrentTime(60)))
    }

    func testSeekForwardUnexpectedly1() {
        let failure = expectFailure(for: .seekForward, model: .waitingForURL)
        expect(failure, .notReadyToPlay)
    }

    func testSeekForwardUnexpectedly2() {
        let failure = expectFailure(for: .seekForward, model: .readyToLoadURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testSeekForwardUnexpectedly3() {
        let failure = expectFailure(for: .seekForward, model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .notReadyToPlay)
    }

    func testUserDidTapPlayButtonWhenReadyToLoadURL() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPlayButton), model: .readyToLoadURL(.arbitrary))
        expect(update?.model, .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.command, .player(.loadURL(.arbitrary)))
    }

    func testUserDidTapPlayButtonWhenReadyToPlayAndNotPlaying() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPlayButton), model: .readyToPlay(.init(isPlaying: false)))
        expect(update?.model, .readyToPlay(.init(isPlaying: true)))
        expect(update?.command, .player(.play))
    }

    func testUserDidTapPlayButtonWhenWaitingForURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), model: .waitingForURL)
        expect(failure, .noURL)
    }

    func testUserDidTapPlayButtonWhenWaitingForPlayerToBecomeReadyToPlayURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(failure, .waitingToBecomeReadyToPlay)
    }

    func testUserDidTapPlayButtonWhenReadyToPlayAndPlaying() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPlayButton), model: .readyToPlay(.init(isPlaying: true)))
        expect(failure, .playing)
    }

    func testUserDidTapPauseButtonWhenWaitingForPlayerToBecomeReadyToPlayURL() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), model: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(update?.model, .readyToLoadURL(.arbitrary))
        expect(update?.command, .player(.loadURL(nil)))
    }

    func testUserDidTapPauseButtonWhenReadyToPlayAndPlaying() {
        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), model: .readyToPlay(.init(isPlaying: true)))
        expect(update?.model, .readyToPlay(.init(isPlaying: false)))
        expect(update?.command, .player(.pause))
    }

    func testUserDidTapPauseButtonWhenWaitingForURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), model: .waitingForURL)
        expect(failure, .noURL)
    }

    func testUserDidTapPauseButtonWhenReadyToLoadURL() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), model: .readyToLoadURL(.arbitrary))
        expect(failure, .readyToLoadURL)
    }

    func testUserDidTapPauseButtonWhenReadyToPlayAndNotPlaying() {
        let failure = expectFailure(for: .playPauseButton(.userDidTapPauseButton), model: .readyToPlay(.init(isPlaying: false)))
        expect(failure, .notPlaying)
    }

    // MARK: View

    func testViewWhenWaitingForURL() {
        let view = expectView(for: .waitingForURL)
        expect(view?.playPauseButtonMessage, .userDidTapPlayButton)
        expect(view?.isPlayPauseButtonEnabled, false)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, false)
    }

    func testViewWhenReadyToLoad() {
        let view = expectView(for: .readyToLoadURL(.arbitrary))
        expect(view?.playPauseButtonMessage, .userDidTapPlayButton)
        expect(view?.isPlayPauseButtonEnabled, true)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, false)
    }

    func testViewWhenWaitingForPlayer() {
        let view = expectView(for: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
        expect(view?.playPauseButtonMessage, .userDidTapPauseButton)
        expect(view?.isPlayPauseButtonEnabled, true)
        expect(view?.areSeekButtonsHidden, true)
        expect(view?.playbackTime, "")
        expect(view?.isSeekBackButtonEnabled, false)
        expect(view?.isSeekForwardButtonEnabled, false)
        expect(view?.isLoadingIndicatorVisible, true)
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
        expect(view?.playPauseButtonMessage, .userDidTapPlayButton)
    }

    func testPlayPauseButtonMode2() {
        let view = expectView(for: .readyToPlay(.init(isPlaying: true)))
        expect(view?.playPauseButtonMessage, .userDidTapPauseButton)
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

extension AudioBar.Model.ReadyState {
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
