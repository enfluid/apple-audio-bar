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
        state.prepareToLoad(url: .foo)
        expect(state.nextState, equals: ReadyToLoadURLState(url: .foo))
    }

}

extension WaitingForURLStateTests {

    func testView() {
        let view = state.present() as! AudioBarView
        expect(view.playPauseButtonImage, equals: .play)
        expect(view.isPlayPauseButtonEnabled, equals: false)
        expect(view.areSeekButtonsHidden, equals: true)
        expect(view.playbackTime, equals: "")
        expect(view.isSeekBackButtonEnabled, equals: false)
        expect(view.isSeekForwardButtonEnabled, equals: false)
        expect(view.isLoadingIndicatorVisible, equals: false)
        expect(view.isPlayCommandEnabled, equals: false)
        expect(view.isPauseCommandEnabled, equals: false)
        expect(view.seekInterval, equals: 0)
        expect(view.playbackDuration, equals: 0)
        expect(view.elapsedPlaybackTime, equals: 0)
        expect(view.trackName, equals: nil)
        expect(view.artistName, equals: nil)
        expect(view.albumName, equals: nil)
    }

}