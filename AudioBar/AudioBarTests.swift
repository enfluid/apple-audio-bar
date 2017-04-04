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

    // MARK: - Waiting for player to load URL

    func test_WaitingForPlayerToLoadURL_Idle1() {
        let view = expectView(for: .didMutate, state: .waitingForPlayerToLoad(.foo))
        expect(view?.playPauseButtonImage, equals: .pause)
        expect(view?.isPlayPauseButtonEnabled, equals: true)
        expect(view?.isPlayCommandEnabled, equals: false)
        expect(view?.isPauseCommandEnabled, equals: true)
        expect(view?.areSeekButtonsHidden, equals: true)
        expect(view?.playbackTime, equals: "")
        expect(view?.isSeekBackButtonEnabled, equals: false)
        expect(view?.isSeekForwardButtonEnabled, equals: false)
        expect(view?.isLoadingIndicatorVisible, equals: true)
        expect(view?.seekInterval, equals: 15)
        expect(view?.playbackDuration, equals: 0)
        expect(view?.elapsedPlaybackTime, equals: 0)
        expect(view?.trackName, equals: nil)
        expect(view?.artistName, equals: nil)
        expect(view?.albumName, equals: nil)
    }

    func test_WaitingForPlayerToLoadURL_Idle2() {
        expectIdle(for: .didPresent, state: .waitingForPlayerToLoad(.foo))
    }

    // MARK: + Player did become ready

    func test_WaitingForPlayerToLoadURL_PlayerDidDidBecomeReady_Event() {
        let action = expectAction(for: .didReceive(.playerDidBecomeReady), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.play))
    }

    func test_WaitingForPlayerToLoadURL_PlayerDidDidBecomeReady_Action1() {
        let action = expectAction(for: .didPerform(.player(.play), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.getInfo))
    }

    func test_WaitingForPlayerToLoadURL_PlayerDidDidBecomeReady_Action2() {
        typealias PlayerInfo = StateMachine.Action.Player.Info
        let state = expectState(for: .didPerform(.player(.getInfo), result: AudioBar.Action.Player.Info()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .readyToPlay(.init(isPlaying: true, currentTime: nil, info: .init())))
    }

    // MARK: + Player did fail to become ready

    func test_WaitingForPlayerToLoadURL_PlayerDidFailToBecomeReady_Event() {
        let action = expectAction(for: .didReceive(.playerDidFailToBecomeReady), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .showAlert(text: "Unable to load media", button: "OK"))
    }

    func test_WaitingForPlayerToLoadURL_PlayerDidFailToBecomeReady_Action() {
        let state = expectState(for: .didPerform(.showAlert(text: "Unable to load media", button: "OK"), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .readyToLoadURL(.foo))
    }

    // MARK: + User did tap play/pause button

    func test_WaitingForPlayerToLoadURL_UserDidTapPlayPauseButton_Event1() {
        let action = expectAction(for: .didReceive(.userDidTapPlayPauseButton), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoadURL_UserDidTapPlayPauseButton_Event2() {
        let action = expectAction(for: .didReceive(.userDidTapPauseButton), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoadURL_UserDidTapPlayPauseButton_Action() {
        // WARNING: Duplicate (1)
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .waitingForURL)
    }

    // MARK: + Reset

    func test_WaitingForPlayerToLoadURL_Reset_Event() {
        let action = expectAction(for: .didReceive(.reset), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoadURL_Reset_Action() {
        // WARNING: Duplicate (2)
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .waitingForURL)
    }

    // MARK: - Ready to play

    func test_ReadyToPlay_View_PlayPauseButtonImage1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true)))
        expect(view?.playPauseButtonImage, equals: .pause)
    }

    func test_ReadyToPlay_View_PlayPauseButtonImage2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false)))
        expect(view?.playPauseButtonImage, equals: .play)
    }

    func test_ReadyToPlay_View_PlaybackTime1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.playbackTime, equals: "")
    }

    func test_ReadyToPlay_View_PlaybackTime2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 1))))
        expect(view?.playbackTime, equals: "-0:01")
    }

    func test_ReadyToPlay_View_PlaybackTime3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 61))))
        expect(view?.playbackTime, equals: "-1:01")
    }

    func test_ReadyToPlay_View_PlaybackTime4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 20, info: .init(duration: 60))))
        expect(view?.playbackTime, equals: "-0:40")
    }

    func test_ReadyToPlay_View_PlaybackDuration1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(duration: 1))))
        expect(view?.playbackDuration, equals: 1)
    }

    func test_ReadyToPlay_View_PlaybackDuration2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(duration: 2))))
        expect(view?.playbackDuration, equals: 2)
    }

    func test_ReadyToPlay_View_ElapsedPlaybackTime1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.elapsedPlaybackTime, equals: 0)
    }

    func test_ReadyToPlay_View_ElapsedPlaybackTime2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 1)))
        expect(view?.elapsedPlaybackTime, equals: 1)
    }

    func test_ReadyToPlay_View_ElapsedPlaybackTime3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 2)))
        expect(view?.elapsedPlaybackTime, equals: 2)
    }

    func test_ReadyToPlay_View_SeekIntervalWhenReadyToPlay() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init()))
        expect(view?.seekInterval, equals: 15)
    }

    func test_ReadyToPlay_View_IsPlayCommandEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true)))
        expect(view?.isPlayCommandEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsPlayCommandEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 0, info: .init(duration: 1))))
        expect(view?.isPlayCommandEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsPlayCommandEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 1, info: .init(duration: 1))))
        expect(view?.isPlayCommandEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsPauseCommandEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false)))
        expect(view?.isPauseCommandEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsPauseCommandEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 0, info: .init(duration: 1))))
        expect(view?.isPauseCommandEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsPauseCommandEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 1, info: .init(duration: 1))))
        expect(view?.isPauseCommandEnabled, equals: false)
    }

    func test_ReadyToPlay_View_TrackName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: nil))))
        expect(view?.trackName, equals: nil)
    }

    func test_ReadyToPlay_View_TrackName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: "1"))))
        expect(view?.trackName, equals: "1")
    }

    func test_ReadyToPlay_View_TrackName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: "2"))))
        expect(view?.trackName, equals: "2")
    }

    func test_ReadyToPlay_View_ArtistName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: nil))))
        expect(view?.artistName, equals: nil)
    }

    func test_ReadyToPlay_View_ArtistName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: "3"))))
        expect(view?.artistName, equals: "3")
    }

    func test_ReadyToPlay_View_ArtistName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: "4"))))
        expect(view?.artistName, equals: "4")
    }

    func test_ReadyToPlay_View_AlbumName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: nil))))
        expect(view?.albumName, equals: nil)
    }

    func test_ReadyToPlay_View_AlbumName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: "5"))))
        expect(view?.albumName, equals: "5")
    }

    func test_ReadyToPlay_View_AlbumName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: "6"))))
        expect(view?.albumName, equals: "6")
    }

    func test_ReadyToPlay_View_ArtworkData1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artwork: nil))))
        expect(view?.artworkData, equals: nil)
    }

    func test_ReadyToPlay_View_ArtworkData2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artwork: Data()))))
        expect(view?.artworkData, equals: Data())
    }

    func test_ReadyToPlay_View_IsLoadingIndicatorVisible1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, equals: true)
    }

    func test_ReadyToPlay_View_IsLoadingIndicatorVisible2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func test_ReadyToPlay_View_IsLoadingIndicatorVisible3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func test_ReadyToPlay_View_IsLoadingIndicatorVisible4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func test_ReadyToPlay_View_IsSeekBackButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekBackButtonEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsSeekBackButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsSeekBackButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 1, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsSeekBackButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 2, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsSeekForwardButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekForwardButtonEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsSeekForwardButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 58, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsSeekForwardButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 59, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsSeekForwardButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 60, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsPlayPauseButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsPlayPauseButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 60, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: false)
    }

    func test_ReadyToPlay_View_IsPlayPauseButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 59, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_View_IsPlayPauseButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 58, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func test_ReadyToPlay_Idle() {
        expectIdle(for: .didPresent, state: .readyToPlay(.init()))
    }

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
