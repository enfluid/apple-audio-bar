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

final class ReadyToPlayStateTests: XCTestCase {}

extension ReadyToPlayStateTests {

    func testViewPlayPauseButtonImage1() {
        let state = ReadyToPlayState(isPlaying: true)
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .pause)
    }

    func testViewPlayPauseButtonImage2() {
        let state = ReadyToPlayState(isPlaying: false)
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .play)
    }

    func testViewPlaybackTime1() {
        let state = ReadyToPlayState(currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "")
    }

    func testViewPlaybackTime2() {
        let state = ReadyToPlayState(currentTime: 0, info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:01")
    }

    func testViewPlaybackTime3() {
        let state = ReadyToPlayState(currentTime: 0, info: .init(duration: 61))
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-1:01")
    }

    func testViewPlaybackTime4() {
        let state = ReadyToPlayState(currentTime: 20, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:40")
    }

    func testViewPlaybackDuration1() {
        let state = ReadyToPlayState(info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.playbackDuration, equals: 1)
    }

    func testViewPlaybackDuration2() {
        let state = ReadyToPlayState(info: .init(duration: 2))
        let view = state.present() as! AudioBarView
        expect(view.playbackDuration, equals: 2)
    }

    func testViewElapsedPlaybackTime1() {
        let state = ReadyToPlayState(currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: 0)
    }

    func testViewElapsedPlaybackTime2() {
        let state = ReadyToPlayState(currentTime: 1)
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: 1)
    }

    func testViewElapsedPlaybackTime3() {
        let state = ReadyToPlayState(currentTime: 2)
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: 2)
    }

    func testViewSeekIntervalWhenReadyToPlay() {
        let state = ReadyToPlayState()
        let view = state.present() as! AudioBarView
        expect(view.seekInterval, equals: 15)
    }

    func testViewIsPlayCommandEnabled1() {
        let state = ReadyToPlayState(isPlaying: true)
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

    func testViewIsPlayCommandEnabled2() {
        let state = ReadyToPlayState(isPlaying: false, currentTime: 0, info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: true)
    }

    func testViewIsPlayCommandEnabled3() {
        let state = ReadyToPlayState(isPlaying: false, currentTime: 1, info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

    func testViewIsPauseCommandEnabled1() {
        let state = ReadyToPlayState(isPlaying: false)
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

    func testViewIsPauseCommandEnabled2() {
        let state = ReadyToPlayState(isPlaying: true, currentTime: 0, info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: true)
    }

    func testViewIsPauseCommandEnabled3() {
        let state = ReadyToPlayState(isPlaying: true, currentTime: 1, info: .init(duration: 1))
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

    func testViewTrackName1() {
        let state = ReadyToPlayState(info: .init(title: nil))
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: nil)
    }

    func testViewTrackName2() {
        let state = ReadyToPlayState(info: .init(title: "1"))
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "1")
    }

    func testViewTrackName3() {
        let state = ReadyToPlayState(info: .init(title: "2"))
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "2")
    }

    func testViewArtistName1() {
        let state = ReadyToPlayState(info: .init(artist: nil))
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: nil)
    }

    func testViewArtistName2() {
        let state = ReadyToPlayState(info: .init(artist: "3"))
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "3")
    }

    func testViewArtistName3() {
        let state = ReadyToPlayState(info: .init(artist: "4"))
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "4")
    }

    func testViewAlbumName1() {
        let state = ReadyToPlayState(info: .init(album: nil))
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: nil)
    }

    func testViewAlbumName2() {
        let state = ReadyToPlayState(info: .init(album: "5"))
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "5")
    }

    func testViewAlbumName3() {
        let state = ReadyToPlayState(info: .init(album: "6"))
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "6")
    }

    func testViewArtworkData1() {
        let state = ReadyToPlayState(info: .init(artwork: nil))
        let view = state.present() as! AudioBarView
        expect(view.artworkData, equals: nil)
    }

    func testViewArtworkData2() {
        let state = ReadyToPlayState(info: .init(artwork: Data()))
        let view = state.present() as! AudioBarView

        // TODO: Fix `expect`:
        // 1. Improve error message (dump -> describing)
        // 2. Improve handling Equatables, e.g. Data() equal to Data()

        expect(view.artworkData, equals: Data())
    }

    func testViewIsLoadingIndicatorVisible1() {
        let state = ReadyToPlayState(isPlaying: true, currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: true)
    }

    func testViewIsLoadingIndicatorVisible2() {
        let state = ReadyToPlayState(isPlaying: false, currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsLoadingIndicatorVisible3() {
        let state = ReadyToPlayState(isPlaying: true, currentTime: 0)
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsLoadingIndicatorVisible4() {
        let state = ReadyToPlayState(isPlaying: false, currentTime: 0)
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testViewIsSeekBackButtonEnabled1() {
        let state = ReadyToPlayState(currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testViewIsSeekBackButtonEnabled2() {
        let state = ReadyToPlayState(currentTime: 0, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testViewIsSeekBackButtonEnabled3() {
        let state = ReadyToPlayState(currentTime: 1, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

    func testViewIsSeekBackButtonEnabled4() {
        let state = ReadyToPlayState(currentTime: 2, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled1() {
        let state = ReadyToPlayState(currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

    func testViewIsSeekForwardButtonEnabled2() {
        let state = ReadyToPlayState(currentTime: 58, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled3() {
        let state = ReadyToPlayState(currentTime: 59, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testViewIsSeekForwardButtonEnabled4() {
        let state = ReadyToPlayState(currentTime: 60, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

    func testViewIsPlayPauseButtonEnabled1() {
        let state = ReadyToPlayState(currentTime: nil)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testViewIsPlayPauseButtonEnabled2() {
        let state = ReadyToPlayState(currentTime: 60, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: false)
    }

    func testViewIsPlayPauseButtonEnabled3() {
        let state = ReadyToPlayState(currentTime: 59, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testViewIsPlayPauseButtonEnabled4() {
        let state = ReadyToPlayState(currentTime: 58, info: .init(duration: 60))
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

}
