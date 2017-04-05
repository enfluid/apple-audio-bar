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

final class ReadyToPlayStateViewTests: XCTestCase {

    public var state = ReadyToPlayState()
    
}

extension ReadyToPlayStateViewTests {

    func testPlayPauseButtonImage1() {
        state.isPlaying = true
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .pause)
    }

    func testPlayPauseButtonImage2() {
        state.isPlaying = false
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .play)
    }

    func testPlaybackTime1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "")
    }

}

extension ReadyToPlayStateViewTests {

    func testPlaybackTime2() {
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:01")
    }

    func testPlaybackTime3() {
        state.currentTime = 0
        state.info = .init(duration: 61)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-1:01")
    }

    func testPlaybackTime4() {
        state.currentTime = 20
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.playbackTime, equals: "-0:40")
    }

}

extension ReadyToPlayStateViewTests {

    func testPlaybackDuration() {
        state.info = .init(duration: .foo)
        let view = state.present() as! AudioBarView
        expect(view.playbackDuration, equals: .foo)
    }

}

extension ReadyToPlayStateViewTests {

    func testElapsedPlaybackTime1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: 0)
    }

    func testElapsedPlaybackTime2() {
        state.currentTime = .foo
        let view = state.present() as! AudioBarView
        expect(view.elapsedPlaybackTime, equals: .foo)
    }

}

extension ReadyToPlayStateViewTests {

    func testSeekIntervalWhenReadyToPlay() {
        let view = state.present() as! AudioBarView
        expect(view.seekInterval, equals: 15)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPlayCommandEnabled1() {
        state.isPlaying = true
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

    func testIsPlayCommandEnabled2() {
        state.isPlaying = false
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: true)
    }

    func testIsPlayCommandEnabled3() {
        state.isPlaying = false
        state.currentTime = 1
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPlayCommandEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPauseCommandEnabled1() {
        state.isPlaying = false
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

    func testIsPauseCommandEnabled2() {
        state.isPlaying = true
        state.currentTime = 0
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: true)
    }

    func testIsPauseCommandEnabled3() {
        state.isPlaying = true
        state.currentTime = 1
        state.info = .init(duration: 1)
        let view = state.present() as! AudioBarView
        expect(view.isPauseCommandEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testTrackName1() {
        state.info = .init(title: nil)
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: nil)
    }

    func testTrackName2() {
        state.info = .init(title: "A")
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "A")
    }

    func testTrackName3() {
        state.info = .init(title: "B")
        let view = state.present() as! AudioBarView
        expect(view.trackName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testArtistName1() {
        state.info = .init(artist: nil)
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: nil)
    }

    func testArtistName2() {
        state.info = .init(artist: "A")
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "A")
    }

    func testArtistName3() {
        state.info = .init(artist: "B")
        let view = state.present() as! AudioBarView
        expect(view.artistName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testAlbumName1() {
        state.info = .init(album: nil)
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: nil)
    }

    func testAlbumName2() {
        state.info = .init(album: "A")
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "A")
    }

    func testAlbumName3() {
        state.info = .init(album: "B")
        let view = state.present() as! AudioBarView
        expect(view.albumName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testArtworkData1() {
        state.info = .init(artwork: nil)
        let view = state.present() as! AudioBarView
        expect(view.artworkData, equals: nil)
    }

    func testArtworkData2() {
        state.info = .init(artwork: .init())
        let view = state.present() as! AudioBarView
        expect(view.artworkData, equals: .init())
    }

}

extension ReadyToPlayStateViewTests {

    func testIsLoadingIndicatorVisible1() {
        state.isPlaying = true
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: true)
    }

    func testIsLoadingIndicatorVisible2() {
        state.isPlaying = false
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible3() {
        state.isPlaying = true
        state.currentTime = 0
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible4() {
        state.isPlaying = false
        state.currentTime = 0
        let view = state.present() as! AudioBarView
        expect(view.isLoadingIndicatorVisible, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsSeekBackButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled2() {
        state.currentTime = 0
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled3() {
        state.currentTime = 1
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

    func testIsSeekBackButtonEnabled4() {
        state.currentTime = 2
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekBackButtonEnabled, equals: true)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsSeekForwardButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

    func testIsSeekForwardButtonEnabled2() {
        state.currentTime = 59
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled3() {
        state.currentTime = 119
        state.info = .init(duration: 120)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled4() {
        state.currentTime = 60
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isSeekForwardButtonEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPlayPauseButtonEnabled1() {
        state.currentTime = nil
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled2() {
        state.currentTime = 60
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: false)
    }

    func testIsPlayPauseButtonEnabled3() {
        state.currentTime = 59
        state.info = .init(duration: 60)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled4() {
        state.currentTime = 119
        state.info = .init(duration: 120)
        let view = state.present() as! AudioBarView
        expect(view.isPlayPauseButtonEnabled, equals: true)
    }
    
}
