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

public struct AudioBarView: View {

    public enum PlayPauseButtonImage {
        case play
        case pause
    }

    public let playPauseButtonImage: PlayPauseButtonImage
    public let isPlayPauseButtonEnabled: Bool
    public let areSeekButtonsHidden: Bool
    public let playbackTime: String
    public let isSeekBackButtonEnabled: Bool
    public let isSeekForwardButtonEnabled: Bool
    public let isLoadingIndicatorVisible: Bool
    public let isPlayCommandEnabled: Bool
    public let isPauseCommandEnabled: Bool
    public let seekInterval: TimeInterval
    public let playbackDuration: TimeInterval
    public let elapsedPlaybackTime: TimeInterval
    public let trackName: String?
    public let artistName: String?
    public let albumName: String?
    public let artworkData: Data?

}
