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

struct WaitingForPlayerToLoadState: State, Effectful {

    let url: URL
    let world = World.shared
    var nextState: State?

    init(url: URL) {
        self.url = url
    }

}

extension WaitingForPlayerToLoadState {

    public mutating func onPlayerDidBecomeReady() {
        world.perform(Player.PlayAction())
        let info = world.perform(Player.GetInfoAction())
        nextState = ReadyToPlayState(isPlaying: true, currentTime: nil, info: info)
    }

    public mutating func onPlayerDidFailToBecomeReady() {
        let showAlertAction = ShowAlertAction(text: "Unable to load media", button: "OK")
        world.perform(showAlertAction)
        nextState = ReadyToLoadURLState(url: url)
    }

    public mutating func onUserDidTapPauseButton() {
        world.perform(Player.LoadAction(url: nil))
        nextState = ReadyToLoadURLState(url: url)
    }

}

extension WaitingForPlayerToLoadState {

    public mutating func reset() {
        world.perform(Player.LoadAction(url: nil))
        nextState = WaitingForURLState()
    }

}

extension WaitingForPlayerToLoadState: Presentable {

    func present() -> View {
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

