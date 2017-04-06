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

public struct WaitingForPlayerToLoadState: State, Effectful {

    fileprivate let url: URL

    public let world = World.shared
    public var nextState: State?

    init(url: URL) {
        self.url = url
    }

}

extension WaitingForPlayerToLoadState {

    public mutating func prepareToLoad(_ url: URL?) {
        world.send(Player.Load(url: nil))
        if let url = url {
            nextState = ReadyToLoadURLState(url: url)
        } else {
            nextState = WaitingForURLState()
        }
    }

}

extension WaitingForPlayerToLoadState {

    public mutating func onPlayerDidBecomeReady() {
        world.send(Player.PlayingUpdate(isPlaying: true))
        nextState = ReadyToPlayState()
    }

    public mutating func onPlayerDidFailToBecomeReady() {
        world.send(ShowAlertAction(text: "Unable to load media", button: "OK"))
        nextState = ReadyToLoadURLState(url: url)
    }

}

extension WaitingForPlayerToLoadState {

    public mutating func onUserDidTapPauseButton() {
        stop()
    }

    public mutating func onUserDidTapPlayPauseButton() {
        stop()
    }

    private mutating func stop() {
        world.send(Player.Load(url: nil))
        nextState = ReadyToLoadURLState(url: url)
    }

}

extension WaitingForPlayerToLoadState: Presentable {

    public func present() -> View {
        return AudioBarView(
            playPauseButtonImage: .pause,
            isPlayPauseButtonEnabled: true,
            areSeekButtonsHidden: true,
            playbackTime: "",
            isSeekBackButtonEnabled: false,
            isSeekForwardButtonEnabled: false,
            isLoadingIndicatorVisible: true,
            isPlayCommandEnabled: false,
            isPauseCommandEnabled: true,
            seekInterval: 0,
            playbackDuration: 0,
            elapsedPlaybackTime: 0,
            trackName: nil,
            artistName: nil,
            albumName: nil,
            artworkData: nil
        )
    }

}
