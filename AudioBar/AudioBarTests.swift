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

    // MARK: - Waiting for URL

    func test_WaitingForURL_1() {
        let view = expectView(for: .didMutate, state: .waitingForURL)
        expect(view?.isPlayPauseButtonEnabled, equals: false)
        expect(view?.areSeekButtonsHidden, equals: true)
        expect(view?.playbackTime, equals: "")
        expect(view?.isSeekBackButtonEnabled, equals: false)
        expect(view?.isSeekForwardButtonEnabled, equals: false)
        expect(view?.isLoadingIndicatorVisible, equals: false)
        expect(view?.isPlayCommandEnabled, equals: false)
        expect(view?.isPauseCommandEnabled, equals: false)
        expect(view?.seekInterval, equals: 15)
        expect(view?.playbackDuration, equals: 0)
        expect(view?.elapsedPlaybackTime, equals: 0)
        expect(view?.trackName, equals: nil)
        expect(view?.artistName, equals: nil)
        expect(view?.albumName, equals: nil)
    }

    func test_WaitingForURL_2() {
        expectIdle(for: .didPresent, state: .waitingForURL)
    }

    // MARK: + Prepare to load URL

    func test_WaitingForURL_PrepareToLoadURL_Event() {
        let state = expectState(for: .didReceive(.prepareToLoad(.foo)), state: .waitingForURL)
        expect(state, equals: .readyToLoadURL(URL.foo))
    }

    // MARK: + Reset

    func test_WaitingForURL_Reset() {
        expectIdle(for: .didReceive(.reset), state: .waitingForURL)
    }

    // MARK: - Ready to load URL

    func test_ReadyToLoadURL_1() {
        let view = expectView(for: .didMutate, state: .readyToLoadURL(.foo))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
        expect(view?.areSeekButtonsHidden, equals: true)
        expect(view?.isPlayCommandEnabled, equals: true)
        expect(view?.isPauseCommandEnabled, equals: false)
        expect(view?.playbackTime, equals: "")
        expect(view?.isSeekBackButtonEnabled, equals: false)
        expect(view?.isSeekForwardButtonEnabled, equals: false)
        expect(view?.isLoadingIndicatorVisible, equals: false)
        expect(view?.seekInterval, equals: 15)
        expect(view?.playbackDuration, equals: 0)
        expect(view?.elapsedPlaybackTime, equals: 0)
        expect(view?.trackName, equals: nil)
        expect(view?.artistName, equals: nil)
        expect(view?.albumName, equals: nil)
    }

    func test_ReadyToLoadURL_2() {
        expectIdle(for: .didPresent, state: .readyToLoadURL(.foo))
    }

    // MARK: + User did tap play/pause button

    func test_ReadyToLoadURL_UserDidTapPlayPauseButton_1() {
        let action = expectAction(for: .didReceive(.userDidTapPlayButton), state: .readyToLoadURL(.foo))
        expect(action, equals: .player(.load(URL.foo)))
    }

    func test_ReadyToLoadURL_UserDidTapPlayPauseButton_2() {
        let action = expectAction(for: .didReceive(.userDidTapPlayPauseButton), state: .readyToLoadURL(.foo))
        expect(action, equals: .player(.load(URL.foo)))
    }

    func test_ReadyToLoadURL_UserDidTapPlayPauseButton_3() {
        let state = expectState(for: .didPerform(.player(.load(URL.foo)), result: Void()), state: .readyToLoadURL(.foo))
        expect(state, equals: .waitingForPlayerToLoad(.foo))
    }

    // MARK: + Reset

    func test_ReadyToLoadURL_Reset() {
        let state = expectState(for: .didReceive(.reset), state: .readyToLoadURL(.foo))
        expect(state, equals: .waitingForURL)
    }

    // MARK: - Waiting for player

    func testWaitingForPlayerView() {
        let view = expectView(for: .didMutate, state: .waitingForPlayerToLoad(.foo))
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

    func testWaitingForPlayerIdle() {
        expectIdle(for: .didPresent, state: .waitingForPlayerToLoad(.foo))
    }

    func testWaitingForPlayerFail1() {
            let action = expectAction(for: .didReceive(.playerDidFailToBecomeReady), state: .waitingForPlayerToLoad(.foo))
            expect(action, equals: .showAlert(text: "Unable to load media", button: "OK"))
    }

    func testWaitingForPlayerFail2() {
        let state = expectState(for: .didPerform(.showAlert(text: "Unable to load media", button: "OK"), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .readyToLoadURL(.foo))
    }

    func testWaitingForPlayerPlay() {
        let action = expectAction(
            for: .didReceive(.playerDidBecomeReady),
            state: .waitingForPlayerToLoad(.foo)
        )
        expect(action, equals: .player(.play))
    }

    func testWaitingForPlayerGetInfo() {
        let action = expectAction(
            for: .didPerform(.player(.play), result: Void()),
            state: .waitingForPlayerToLoad(.foo)
        )
        expect(action, equals: .player(.getInfo))
    }

    func testWaitingForPlayerAdvance() {
        typealias PlayerInfo = StateMachine.Action.Player.Info
        let state = expectState(
            for: .didPerform(.player(.getInfo), result: AudioBar.Action.Player.Info()),
            state: .waitingForPlayerToLoad(.foo)
        )
        expect(state, equals: .readyToPlay(.init(isPlaying: true, currentTime: nil, info: .init())))
    }

    func testWaitingForPlayerReturn() {
        let state = expectState(
            for: .didPerform(.player(.load(nil)), result: Void()),
            state: .waitingForPlayerToLoad(.foo)
        )
        expect(state, equals: .waitingForURL)
    }

    // MARK: + User did tap play/pause button

    func test_WaitingForPlayerToLoad_UserDidTapPlayPauseButton_1() {
        let action = expectAction(for: .didReceive(.userDidTapPlayPauseButton), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoad_UserDidTapPlayPauseButton_2() {
        let action = expectAction(for: .didReceive(.userDidTapPauseButton), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoad_UserDidTapPlayPauseButton_3() {
        // WARNING: Duplicate (1)
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .waitingForURL)
    }

    // MARK: + Reset

    func test_WaitingForPlayerToLoad_Reset1() {
        let action = expectAction(for: .didReceive(.reset), state: .waitingForPlayerToLoad(.foo))
        expect(action, equals: .player(.load(nil)))
    }

    func test_WaitingForPlayerToLoad_Reset2() {
        // WARNING: Duplicate (2)
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .waitingForPlayerToLoad(.foo))
        expect(state, equals: .waitingForURL)
    }

    // MARK: - Ready to play

    func testPlaybackTime1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.playbackTime, equals: "")
    }

    func testPlaybackTime2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 1))))
        expect(view?.playbackTime, equals: "-0:01")
    }

    func testPlaybackTime3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 61))))
        expect(view?.playbackTime, equals: "-1:01")
    }

    func testPlaybackTime4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 20, info: .init(duration: 60))))
        expect(view?.playbackTime, equals: "-0:40")
    }

    func testPlaybackDuration1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(duration: 1))))
        expect(view?.playbackDuration, equals: 1)
    }

    func testPlaybackDuration2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(duration: 2))))
        expect(view?.playbackDuration, equals: 2)
    }

    func testElapsedPlaybackTime1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.elapsedPlaybackTime, equals: 0)
    }

    func testElapsedPlaybackTime2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 1)))
        expect(view?.elapsedPlaybackTime, equals: 1)
    }

    func testElapsedPlaybackTime3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 2)))
        expect(view?.elapsedPlaybackTime, equals: 2)
    }

    func testSeekIntervalWhenReadyToPlay() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init()))
        expect(view?.seekInterval, equals: 15)
    }

    func testIsPlayCommandEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true)))
        expect(view?.isPlayCommandEnabled, equals: false)
    }

    func testIsPlayCommandEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 0, info: .init(duration: 1))))
        expect(view?.isPlayCommandEnabled, equals: true)
    }

    func testIsPlayCommandEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 1, info: .init(duration: 1))))
        expect(view?.isPlayCommandEnabled, equals: false)
    }

    func testIsPauseCommandEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false)))
        expect(view?.isPauseCommandEnabled, equals: false)
    }

    func testIsPauseCommandEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 0, info: .init(duration: 1))))
        expect(view?.isPauseCommandEnabled, equals: true)
    }

    func testIsPauseCommandEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 1, info: .init(duration: 1))))
        expect(view?.isPauseCommandEnabled, equals: false)
    }

    func testTrackName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: nil))))
        expect(view?.trackName, equals: nil)
    }

    func testTrackName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: "1"))))
        expect(view?.trackName, equals: "1")
    }

    func testTrackName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(title: "2"))))
        expect(view?.trackName, equals: "2")
    }

    func testArtistName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: nil))))
        expect(view?.artistName, equals: nil)
    }

    func testArtistName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: "3"))))
        expect(view?.artistName, equals: "3")
    }

    func testArtistName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artist: "4"))))
        expect(view?.artistName, equals: "4")
    }

    func testAlbumName1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: nil))))
        expect(view?.albumName, equals: nil)
    }

    func testAlbumName2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: "5"))))
        expect(view?.albumName, equals: "5")
    }

    func testAlbumName3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(album: "6"))))
        expect(view?.albumName, equals: "6")
    }

    func testArtworkData1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artwork: nil))))
        expect(view?.artworkData, equals: nil)
    }

    func testArtworkData2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(info: .init(artwork: Data()))))
        expect(view?.artworkData, equals: Data())
    }

    func testIsLoadingIndicatorVisible1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, equals: true)
    }

    func testIsLoadingIndicatorVisible2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: nil)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: true, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(isPlaying: false, currentTime: 0)))
        expect(view?.isLoadingIndicatorVisible, equals: false)
    }

    func testIsSeekBackButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 1, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: true)
    }

    func testIsSeekBackButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 2, info: .init(duration: 60))))
        expect(view?.isSeekBackButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isSeekForwardButtonEnabled, equals: false)
    }

    func testIsSeekForwardButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 58, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 59, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 60, info: .init(duration: 60))))
        expect(view?.isSeekForwardButtonEnabled, equals: false)
    }

    func testIsPlayPauseButtonEnabled1() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: nil)))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled2() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 60, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: false)
    }

    func testIsPlayPauseButtonEnabled3() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 59, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled4() {
        let view = expectView(for: .didMutate, state: .readyToPlay(.init(currentTime: 58, info: .init(duration: 60))))
        expect(view?.isPlayPauseButtonEnabled, equals: true)
    }

    func testReadyToPlayIdle() {
        expectIdle(for: .didPresent, state: .readyToPlay(.init()))
    }

    func testPlayerDidUpdateCurrentTime1() {
        let state = expectState(for: .didReceive(.playerDidUpdateCurrentTime(1)), state: .readyToPlay(.init(currentTime: 0)))
        expect(state, equals: .readyToPlay(.init(currentTime: 1)))
    }

    func testPlayerDidUpdateCurrentTime2() {
        let state = expectState(for: .didReceive(.playerDidUpdateCurrentTime(2)), state: .readyToPlay(.init(currentTime: 1)))
        expect(state, equals: .readyToPlay(.init(currentTime: 2)))
    }

    func testPlayerDidPlayToEnd() {
        let state = expectState(for: .didReceive(.playerDidPlayToEnd), state: .readyToPlay(.init(isPlaying: true, currentTime: 0, info: .init(duration: 60))))
        expect(state, equals: .readyToPlay(.init(isPlaying: false, currentTime: 60, info: .init(duration: 60))))
    }

    func testUserDidTapSeekBackButton1() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: 60)))
            expect(action, equals: .player(.setCurrentTime(60 - AudioBar.State.seekInterval)))
    }

    func testUserDidTapSeekBackButton2() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: 120)))
        expect(action, equals: .player(.setCurrentTime(120 - AudioBar.State.seekInterval)))
    }

    func testUserDidTapSeekBackButtonNearBeginning1() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: AudioBar.State.seekInterval - 1)))
        expect(action, equals: .player(.setCurrentTime(0)))
    }

    func testUserDidTapSeekBackButtonNearBeginning2() {
        let action = expectAction(for: .didReceive(.userDidTapSeekBackButton), state: .readyToPlay(.init(currentTime: AudioBar.State.seekInterval - 2)))
        expect(action, equals: .player(.setCurrentTime(0)))
    }

    func testPlayerDidSetCurrentTime1() {
        let state = expectState(for: .didPerform(.player(.setCurrentTime(60)), result: Void()), state: .readyToPlay(.init(currentTime: nil)))
        expect(state, equals: .readyToPlay(.init(currentTime: 60)))
    }

    func testPlayerDidSetCurrentTime2() {
        let state = expectState(for: .didPerform(.player(.setCurrentTime(120)), result: Void()), state: .readyToPlay(.init(currentTime: 60)))
        expect(state, equals: .readyToPlay(.init(currentTime: 120)))
    }

    func testUserDidTapSeekForwardButton1() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 0, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(0 + AudioBar.State.seekInterval)))
    }

    func testUserDidTapSeekForwardButton2() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 1, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(1 + AudioBar.State.seekInterval)))
    }

    func testUserDidTapSeekForwardButtonNearEnd1() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 60 - 1, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(60)))
    }

    func testUserDidTapSeekForwardButtonNearEnd2() {
        let action = expectAction(for: .didReceive(.userDidTapSeekForwardButton), state: .readyToPlay(.init(currentTime: 60 - 2, info: .init(duration: 60))))
        expect(action, equals: .player(.setCurrentTime(60)))
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

    // MARK: + Reset

    func test_ReadyToPlay_Reset_1() {
        let action = expectAction(for: .didReceive(.reset), state: .readyToPlay(.init()))
        expect(action, equals: .player(.load(nil)))
    }

    func test_ReadyToPlay_Reset_2() {
        let state = expectState(for: .didPerform(.player(.load(nil)), result: Void()), state: .readyToPlay(.init()))
        expect(state, equals: .waitingForURL)
    }

    //    func testUserDidTapPauseButtonWhenWaitingForPlayerToBecomeReadyToPlayURL() {
    //        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), state: .waitingForPlayerToBecomeReadyToPlayURL(.arbitrary))
    //        expect(update?.state, .readyToLoadURL(.arbitrary))
    //        expect(update?.action, .player(.loadURL(nil)))
    //    }
    //
    //    func testUserDidTapPauseButtonWhenReadyToPlayAndPlaying() {
    //        let update = expectUpdate(for: .playPauseButton(.userDidTapPauseButton), state: .readyToPlay(.init(isPlaying: true)))
    //        expect(update?.state, .readyToPlay(.init(isPlaying: false)))
    //        expect(update?.action, .player(.pause))
    //    }

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

extension AudioTags {
    init(title: String? = nil, artistName: String? = nil, albumName: String? = nil, artworkData: Data? = nil) {
        self.title = title
        self.artistName = artistName
        self.albumName = albumName
        self.artworkData = artworkData
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
