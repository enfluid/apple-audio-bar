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
