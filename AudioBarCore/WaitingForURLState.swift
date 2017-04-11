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

import Foundation
import Stateful

public struct WaitingForURLState: State {

    public var nextState: State?

    public init() {}

    public let playPauseButtonImage: PlayPauseButtonImage = .play
    public let isPlayPauseButtonEnabled = false
    public let areSeekButtonsHidden = true
    public let playbackTime = ""
    public let isSeekBackButtonEnabled = false
    public let isSeekForwardButtonEnabled = false
    public let isLoadingIndicatorVisible = false
    public let isPlayCommandEnabled = false
    public let seekInterval = 0
    public let playbackDuration = 0
    public let elapsedPlaybackTime = 0
    public let trackName: String? = nil
    public let artistName: String? = nil
    public let albumName: String? = nil
    public let artworkData: Data? = nil

}

extension WaitingForURLState {

    public mutating func prepareToLoad(_ url: URL) {
        nextState = ReadyToLoadURLState(url: url)
    }

}
