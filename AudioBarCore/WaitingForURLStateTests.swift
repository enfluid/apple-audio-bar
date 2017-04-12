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

final class WaitingForURLStateTests: XCTestCase {

    fileprivate var state = WaitingForURLState()

}

extension WaitingForURLStateTests {

    func testPrepareToLoad() {
        state.prepareToLoad(.foo)
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

}

extension WaitingForURLStateTests {

    func testState() {
        expect(state.playPauseButtonImage, equals: .play)
        expect(state.isPlayPauseButtonEnabled, equals: false)
        expect(state.areSeekButtonsHidden, equals: true)
        expect(state.playbackTime, equals: "")
        expect(state.isSeekBackButtonEnabled, equals: false)
        expect(state.isSeekForwardButtonEnabled, equals: false)
        expect(state.isLoadingIndicatorVisible, equals: false)
        expect(state.isPlayCommandEnabled, equals: false)
        expect(state.isPauseCommandEnabled, equals: false)
        expect(state.seekInterval, equals: 0)
        expect(state.playbackDuration, equals: 0)
        expect(state.elapsedPlaybackTime, equals: 0)
        expect(state.trackName, equals: nil)
        expect(state.artistName, equals: nil)
        expect(state.albumName, equals: nil)
    }

}
