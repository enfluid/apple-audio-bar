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
import Stateful

@testable import AudioBarCore

final class ReadyToPlayStateViewTests: XCTestCase {

    fileprivate var state = ReadyToPlayState()
    fileprivate var mock: Mock!

    override func setUp() {
        super.setUp()
        mock = injectMock(into: state.world)
    }
    
}

extension ReadyToPlayStateViewTests {

    func testPrepareToLoad1() {
        mock.expect(Player.Load(url: nil))
        state.prepareToLoad(.foo)
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

    func testPrepareToLoad2() {
        mock.expect(Player.Load(url: nil))
        state.prepareToLoad(nil)
        expect(state.nextState, equals: WaitingForURLState())
    }
    
}

extension ReadyToPlayStateViewTests {

    func testPlayPauseButtonImage1() {
        mock.stub(Player.Playing(), result: true)
        expect(audioBarView.playPauseButtonImage, equals: .pause)
    }

    func testPlayPauseButtonImage2() {
        mock.stub(Player.Playing(), result: false)
        expect(audioBarView.playPauseButtonImage, equals: .play)
    }

}

extension ReadyToPlayStateViewTests {

    func testPlaybackTime1() {
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.playbackTime, equals: "")
    }

    func testPlaybackTime2() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.stub(Player.PlaybackDuration(), result: 1)
        expect(audioBarView.playbackTime, equals: "-0:01")
    }

    func testPlaybackTime3() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.stub(Player.PlaybackDuration(), result: 61)
        expect(audioBarView.playbackTime, equals: "-1:01")
    }

    func testPlaybackTime4() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 20)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.playbackTime, equals: "-0:40")
    }

}

extension ReadyToPlayStateViewTests {

    func testPlaybackDuration() {
        mock.stub(Player.PlaybackDuration(), result: .foo)
        expect(audioBarView.playbackDuration, equals: .foo)
    }

}

extension ReadyToPlayStateViewTests {

    func testElapsedPlaybackTime1() {
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.elapsedPlaybackTime, equals: 0)
    }

    func testElapsedPlaybackTime2() {
        mock.stub(Player.ElapsedPlaybackTime(), result: .foo)
        expect(audioBarView.elapsedPlaybackTime, equals: .foo)
    }

}

extension ReadyToPlayStateViewTests {

    func testSeekIntervalWhenReadyToPlay() {
        expect(audioBarView.seekInterval, equals: 15)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPlayCommandEnabled1() {
        mock.stub(Player.Playing(), result: true)
        expect(audioBarView.isPlayCommandEnabled, equals: false)
    }

    func testIsPlayCommandEnabled2() {
        mock.stub(Player.Playing(), result: false)
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.stub(Player.PlaybackDuration(), result: 1)
        expect(audioBarView.isPlayCommandEnabled, equals: true)
    }

    func testIsPlayCommandEnabled3() {
        mock.stub(Player.Playing(), result: false)
        mock.stub(Player.ElapsedPlaybackTime(), result: 1)
        mock.stub(Player.PlaybackDuration(), result: 1)
        expect(audioBarView.isPlayCommandEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPauseCommandEnabled1() {
        mock.stub(Player.Playing(), result: false)
        expect(audioBarView.isPauseCommandEnabled, equals: false)
    }

    func testIsPauseCommandEnabled2() {
        mock.stub(Player.Playing(), result: true)
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.stub(Player.PlaybackDuration(), result: 1)
        expect(audioBarView.isPauseCommandEnabled, equals: true)
    }

    func testIsPauseCommandEnabled3() {
        mock.stub(Player.Playing(), result: true)
        mock.stub(Player.ElapsedPlaybackTime(), result: 1)
        mock.stub(Player.PlaybackDuration(), result: 1)
        expect(audioBarView.isPauseCommandEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testTrackName1() {
        mock.stub(Player.Metadata.TrackName(), result: nil)
        expect(audioBarView.trackName, equals: nil)
    }

    func testTrackName2() {
        mock.stub(Player.Metadata.TrackName(), result: "A")
        expect(audioBarView.trackName, equals: "A")
    }

    func testTrackName3() {
        mock.stub(Player.Metadata.TrackName(), result: "B")
        expect(audioBarView.trackName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testArtistName1() {
        mock.stub(Player.Metadata.ArtistName(), result: nil)
        expect(audioBarView.artistName, equals: nil)
    }

    func testArtistName2() {
        mock.stub(Player.Metadata.ArtistName(), result: "A")
        expect(audioBarView.artistName, equals: "A")
    }

    func testArtistName3() {
        mock.stub(Player.Metadata.ArtistName(), result: "B")
        expect(audioBarView.artistName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testAlbumName1() {
        mock.stub(Player.Metadata.AlbumName(), result: nil)
        expect(audioBarView.albumName, equals: nil)
    }

    func testAlbumName2() {
        mock.stub(Player.Metadata.AlbumName(), result: "A")
        expect(audioBarView.albumName, equals: "A")
    }

    func testAlbumName3() {
        mock.stub(Player.Metadata.AlbumName(), result: "B")
        expect(audioBarView.albumName, equals: "B")
    }

}

extension ReadyToPlayStateViewTests {

    func testArtworkData1() {
        mock.stub(Player.Metadata.ArtworkData(), result: nil)
        expect(audioBarView.artworkData, equals: nil)
    }

    func testArtworkData2() {
        mock.stub(Player.Metadata.ArtworkData(), result: Data(base64Encoded: "A"))
        expect(audioBarView.artworkData, equals: Data(base64Encoded: "A"))
    }

    func testArtworkData3() {
        mock.stub(Player.Metadata.ArtworkData(), result: Data(base64Encoded: "B"))
        expect(audioBarView.artworkData, equals: Data(base64Encoded: "B"))
    }

}

extension ReadyToPlayStateViewTests {

    func testIsLoadingIndicatorVisible1() {
        mock.stub(Player.Playing(), result: true)
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.isLoadingIndicatorVisible, equals: true)
    }

    func testIsLoadingIndicatorVisible2() {
        mock.stub(Player.Playing(), result: false)
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible3() {
        mock.stub(Player.Playing(), result: true)
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        expect(audioBarView.isLoadingIndicatorVisible, equals: false)
    }

    func testIsLoadingIndicatorVisible4() {
        mock.stub(Player.Playing(), result: false)
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        expect(audioBarView.isLoadingIndicatorVisible, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsSeekBackButtonEnabled1() {
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled2() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isSeekBackButtonEnabled, equals: false)
    }

    func testIsSeekBackButtonEnabled3() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 1)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isSeekBackButtonEnabled, equals: true)
    }

    func testIsSeekBackButtonEnabled4() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 2)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isSeekBackButtonEnabled, equals: true)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsSeekForwardButtonEnabled1() {
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.isSeekForwardButtonEnabled, equals: false)
    }

    func testIsSeekForwardButtonEnabled2() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 59)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled3() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 120 - 1)
        mock.stub(Player.PlaybackDuration(), result: 120)
        expect(audioBarView.isSeekForwardButtonEnabled, equals: true)
    }

    func testIsSeekForwardButtonEnabled4() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 60)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isSeekForwardButtonEnabled, equals: false)
    }

}

extension ReadyToPlayStateViewTests {

    func testIsPlayPauseButtonEnabled1() {
        mock.stub(Player.ElapsedPlaybackTime(), result: nil)
        expect(audioBarView.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled2() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 60)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isPlayPauseButtonEnabled, equals: false)
    }

    func testIsPlayPauseButtonEnabled3() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 60 - 1)
        mock.stub(Player.PlaybackDuration(), result: 60)
        expect(audioBarView.isPlayPauseButtonEnabled, equals: true)
    }

    func testIsPlayPauseButtonEnabled4() {
        mock.stub(Player.ElapsedPlaybackTime(), result: 120 - 1)
        mock.stub(Player.PlaybackDuration(), result: 120)
        expect(audioBarView.isPlayPauseButtonEnabled, equals: true)
    }
    
}

extension ReadyToPlayStateViewTests {

    var audioBarView: AudioBarView {
        return state.present() as! AudioBarView
    }

}
