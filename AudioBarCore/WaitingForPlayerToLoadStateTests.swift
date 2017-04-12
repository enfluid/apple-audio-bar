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

final class WaitingForPlayerToLoadStateTests: XCTestCase {

    fileprivate var state = WaitingForPlayerToLoadState(url: .foo)
    fileprivate var mock: Mock!

    override func setUp() {
        super.setUp()
        mock = injectMock(into: state.world)
    }

}

extension WaitingForPlayerToLoadStateTests {

    func testPrepareToLoad1() {
        mock.expect(Player.Load(url: nil))
        state.prepareToLoad(.bar)
        expect(state.nextState, equals: ReadyToLoadURLState(url: .bar))
    }

    func testPrepareToLoad2() {
        mock.expect(Player.Load(url: nil))
        state.prepareToLoad(nil)
        expect(state.nextState, equals: WaitingForURLState())
    }

}

extension WaitingForPlayerToLoadStateTests {

    func testOnPlayerDidBecomeReady() {
        mock.expect(Player.PlayingUpdate(isPlaying: true))
        state.onPlayerDidBecomeReady()
        expect(state.nextState, equals: ReadyToPlayState())
    }

    func testOnPlayerDidFailToBecomeReady() {
        mock.expect(ShowAlertAction(text: "Unable to load media", button: "OK"))
        state.onPlayerDidFailToBecomeReady()
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

}

extension WaitingForPlayerToLoadStateTests {

    func testOnUserDidTapPauseButton() {
        mock.expect(Player.Load(url: nil))
        state.onUserDidTapPauseButton()
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

    func testOnUserDidTapPlayPauseButton() {
        mock.expect(Player.Load(url: nil))
        state.onUserDidTapPlayPauseButton()
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

}

extension WaitingForPlayerToLoadStateTests {

    func testState() {
        expect(state.playPauseButtonImage, equals: .pause)
        expect(state.isPlayPauseButtonEnabled, equals: true)
        expect(state.isPlayCommandEnabled, equals: false)
        expect(state.isPauseCommandEnabled, equals: true)
        expect(state.areSeekButtonsHidden, equals: true)
        expect(state.playbackTime, equals: "")
        expect(state.isSeekBackButtonEnabled, equals: false)
        expect(state.isSeekForwardButtonEnabled, equals: false)
        expect(state.isLoadingIndicatorVisible, equals: true)
        expect(state.seekInterval, equals: 0)
        expect(state.playbackDuration, equals: 0)
        expect(state.elapsedPlaybackTime, equals: 0)
        expect(state.trackName, equals: nil)
        expect(state.artistName, equals: nil)
        expect(state.albumName, equals: nil)
    }

}
