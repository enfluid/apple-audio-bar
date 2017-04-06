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

    func testOnPlayerDidUpdateElapsedPlaybackTime() {
        state.onPlayerDidUpdateElapsedPlaybackTime()
    }

    func testOnPlayerDidEnd() {
        state.onPlayerDidPlayToEnd()
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapPlaybutton() {
        let mock = injectMock(into: state.world)
        mock.expect(Player.PlayingUpdate(isPlaying: true))
        state.onUserDidTapPlayButton()
    }

    func testOnUserDidTapPauseButton() {
        let mock = injectMock(into: state.world)
        mock.expect(Player.PlayingUpdate(isPlaying: false))
        state.onUserDidTapPauseButton()
    }

    func testOnUserDidTapPlayPauseButton1() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.Playing(), result: true)
        mock.expect(Player.PlayingUpdate(isPlaying: false))
        state.onUserDidTapPlayPauseButton()
    }

    func testOnUserDidTapPlayPauseButton2() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.Playing(), result: false)
        mock.expect(Player.PlayingUpdate(isPlaying: true))
        state.onUserDidTapPlayPauseButton()
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapSeekBackButton1() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.ElapsedPlaybackTime(), result: ReadyToPlayState.seekInterval + 1)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 1))
        state.onUserDidTapSeekBackButton()
    }

    func testOnUserDidTapSeekBackButton2() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.ElapsedPlaybackTime(), result: ReadyToPlayState.seekInterval + 2)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 2))
        state.onUserDidTapSeekBackButton()
    }

    func testOnUserDidTapSeekBackButton3() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.ElapsedPlaybackTime(), result: ReadyToPlayState.seekInterval)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 0))
        state.onUserDidTapSeekBackButton()
    }

    func testOnUserDidTapSeekBackButton4() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.ElapsedPlaybackTime(), result: ReadyToPlayState.seekInterval - 1)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 0))
        state.onUserDidTapSeekBackButton()
    }

    func testOnUserDidTapSeekBackButton5() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.ElapsedPlaybackTime(), result: ReadyToPlayState.seekInterval - 2)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 0))
        state.onUserDidTapSeekBackButton()
    }

}

extension ReadyToPlayStateTests {

    func testOnUserDidTapSeekForwardButton1() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.PlaybackDuration(), result: .infinity)
        mock.stub(Player.ElapsedPlaybackTime(), result: 0)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 0 + ReadyToPlayState.seekInterval))
        state.onUserDidTapSeekForwardButton()
    }

    func testOnUserDidTapSeekForwardButton2() {
        let mock = injectMock(into: state.world)
        mock.stub(Player.PlaybackDuration(), result: .infinity)
        mock.stub(Player.ElapsedPlaybackTime(), result: 1)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 1 + ReadyToPlayState.seekInterval))
        state.onUserDidTapSeekForwardButton()
    }

    func testOnUserDidTapSeekForwardButton3() {
        precondition(ReadyToPlayState.seekInterval < 60)
        let mock = injectMock(into: state.world)
        mock.stub(Player.PlaybackDuration(), result: 60)
        mock.stub(Player.ElapsedPlaybackTime(), result: 60 - 1)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 60))
        state.onUserDidTapSeekForwardButton()
    }

    func testOnUserDidTapSeekForwardButton4() {
        precondition(ReadyToPlayState.seekInterval < 60)
        let mock = injectMock(into: state.world)
        mock.stub(Player.PlaybackDuration(), result: 60)
        mock.stub(Player.ElapsedPlaybackTime(), result: 60 - 2)
        mock.expect(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: 60))
        state.onUserDidTapSeekForwardButton()
    }

}

extension ReadyToPlayStateTests {

    func testReset() {
        let mock = injectMock(into: state.world)
        mock.expect(Player.Load(url: nil))
        state.reset()
        expect(state.nextState, equals: WaitingForURLState())
    }

}
