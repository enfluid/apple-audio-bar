// The MIT License (MIT)
//
// Copyright (c) 2017 Enfluid
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest

@testable import AudioBarCore

final class ReadyToPlayStateTests: XCTestCase {

    public var state = ReadyToPlayState()

}

extension ReadyToPlayStateTests {

    func testOnPlayerDidUpdateCurrentTime() {
        state.currentTime = .foo
        state.onPlayerDidUpdateCurrentTime(.bar)
        expect(state.currentTime, equals: .bar)
    }

    func testOnPlayerDidEnd() {
        state.currentTime = .foo
        state.info = .init(duration: .bar)
        state.onPlayerDidPlayToEnd()
        expect(state.isPlaying, equals: false)
        expect(state.currentTime, equals: .bar)
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapPlaybutton() throws {
        state.isPlaying = false
        let mock = injectMock(into: state.world)
        mock.expect(Player.PlayAction())
        try state.onUserDidTapPlayButton()
        expect(state.isPlaying, equals: true)
    }

    func testOnUserDidTapPauseButton() throws {
        state.isPlaying = true
        let mock = injectMock(into: state.world)
        mock.expect(Player.PauseAction())
        try state.onUserDidTapPauseButton()
        expect(state.isPlaying, equals: false)
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapSeekBackButton1() throws {
        state.currentTime = ReadyToPlayState.seekInterval + 1
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 1))
        try state.onUserDidTapSeekBackButton()
        expect(state.currentTime, equals: 1)
    }

    func testOnUserDidTapSeekBackButton2() throws {
        state.currentTime = ReadyToPlayState.seekInterval + 2
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 2))
        try state.onUserDidTapSeekBackButton()
        expect(state.currentTime, equals: 2)
    }

    func testOnUserDidTapSeekBackButton3() throws {
        state.currentTime = ReadyToPlayState.seekInterval
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 0))
        try state.onUserDidTapSeekBackButton()
        expect(state.currentTime, equals: 0)
    }

    func testOnUserDidTapSeekBackButton4() throws {
        state.currentTime = ReadyToPlayState.seekInterval - 1
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 0))
        try state.onUserDidTapSeekBackButton()
        expect(state.currentTime, equals: 0)
    }

    func testOnUserDidTapSeekBackButton5() throws {
        state.currentTime = ReadyToPlayState.seekInterval - 2
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 0))
        try state.onUserDidTapSeekBackButton()
        expect(state.currentTime, equals: 0)
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapSeekForwardButton1() throws {
        state.currentTime = 0
        state.info = .init(duration: .infinity)
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 0 + ReadyToPlayState.seekInterval))
        try state.onUserDidTapSeekForwardButton()
        expect(state.currentTime, equals: 0 + ReadyToPlayState.seekInterval)
    }

    func testOnUserDidTapSeekForwardButton2() throws {
        state.currentTime = 1
        state.info = .init(duration: .infinity)
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 1 + ReadyToPlayState.seekInterval))
        try state.onUserDidTapSeekForwardButton()
        expect(state.currentTime, equals: 1 + ReadyToPlayState.seekInterval)
    }

    func testOnUserDidTapSeekForwardButton3() throws {
        precondition(ReadyToPlayState.seekInterval < 60)
        state.currentTime = 60 - 1
        state.info = .init(duration: 60)
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 60))
        try state.onUserDidTapSeekForwardButton()
        expect(state.currentTime, equals: 60)
    }

    func testOnUserDidTapSeekForwardButton4() throws {
        precondition(ReadyToPlayState.seekInterval < 60)
        state.currentTime = 60 - 2
        state.info = .init(duration: 60)
        let mock = injectMock(into: state.world)
        mock.expect(Player.SeekAction(currentTime: 60))
        try state.onUserDidTapSeekForwardButton()
        expect(state.currentTime, equals: 60)
    }

}

extension ReadyToPlayStateTests {

    func testReset() throws {
        let mock = injectMock(into: state.world)
        mock.expect(Player.LoadAction(url: nil))
        try state.reset()
        expect(state.nextState, equals: WaitingForURLState())
    }

}

extension ReadyToPlayStateTests {

    func testViewPlayPauseButtonImage1() {
        state.isPlaying = true
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .pause)
    }

    func testViewPlayPauseButtonImage2() {
        state.isPlaying = false
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .play)
    }

    func testViewPlaybackTime1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "")
    }

    func testViewPlaybackTime2() {
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:01")
    }

    func testViewPlaybackTime3() {
        state.currentTime = 0
        state.info = .init(duration: 61)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-1:01")
    }

    func testViewPlaybackTime4() {
        state.currentTime = 20
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:40")
    }

    func testViewPlaybackDuration() {
        state.info = .init(duration: .foo)
        let view = state.present() as! AudioBarView
        expect(view.playbackDuration, equals: .foo)
    }

    func testViewElapsedPlaybackTime1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: 0)
    }

    func testViewElapsedPlaybackTime2() {
        state.currentTime = .foo
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: .foo)
    }

    func testViewSeekIntervalWhenReadyToPlay() {
        let view = state.present() as! AudioBarView
        expect(view.seekInterval, equals: 15)
    }

    func testViewIsPlayCommandEnabled1() {
        state.isPlaying = true
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

    func testViewIsPlayCommandEnabled2() {
        state.isPlaying = false
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: true)
    }

    func testViewIsPlayCommandEnabled3() {
        state.isPlaying = false
        state.currentTime = 1
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

    func testViewIsPauseCommandEnabled1() {
        state.isPlaying = false
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

    func testViewIsPauseCommandEnabled2() {
        state.isPlaying = true
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: true)
    }

    func testViewIsPauseCommandEnabled3() {
        state.isPlaying = true
        state.currentTime = 1
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

    func testViewTrackName1() {
        state.info = .init(title: nil)
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: nil)
    }

    func testViewTrackName2() {
        state.info = .init(title: "A")
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "A")
    }

    func testViewTrackName3() {
        state.info = .init(title: "B")
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "B")
    }

    func testViewArtistName1() {
        state.info = .init(artist: nil)
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: nil)
    }

    func testViewArtistName2() {
        state.info = .init(artist: "A")
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "A")
    }

    func testViewArtistName3() {
        state.info = .init(artist: "B")
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "B")
    }

    func testViewAlbumName1() {
        state.info = .init(album: nil)
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: nil)
    }

    func testViewAlbumName2() {
        state.info = .init(album: "A")
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "A")
    }

    func testViewAlbumName3() {
        state.info = .init(album: "B")
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "B")
    }

    func testViewArtworkData1() {
        state.info = .init(artwork: nil)
        let view = state.present() as! AudioBarView
        expect(view.artworkData, equals: nil)
    }

    func testViewArtworkData2() {
        state.info = .init(artwork: .init())
        let view = state.present() as! AudioBarView
        expect(view.artworkData, equals: .init())
    }

    func testViewIsLoadingIndicatorVisible1() {
        state.isPlaying = true
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: true)
    }

    func testViewIsLoadingIndicatorVisible2() {
        state.isPlaying = false
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsLoadingIndicatorVisible3() {
        state.isPlaying = true
        state.currentTime = 0
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsLoadingIndicatorVisible4() {
        state.isPlaying = false
        state.currentTime = 0
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsSeekBackButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testViewIsSeekBackButtonEnabled2() {
        state.currentTime = 0
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testViewIsSeekBackButtonEnabled3() {
        state.currentTime = 1
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

    func testViewIsSeekBackButtonEnabled4() {
        state.currentTime = 2
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

    func testViewIsSeekForwardButtonEnabled2() {
        state.currentTime = 59
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled3() {
        state.currentTime = 119
        state.info = .init(duration: 120)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled4() {
        state.currentTime = 60
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

    func testViewIsPlayPauseButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testViewIsPlayPauseButtonEnabled2() {
        state.currentTime = 60
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: false)
    }

    func testViewIsPlayPauseButtonEnabled3() {
        state.currentTime = 59
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testViewIsPlayPauseButtonEnabled4() {
        state.currentTime = 119
        state.info = .init(duration: 120)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

}
