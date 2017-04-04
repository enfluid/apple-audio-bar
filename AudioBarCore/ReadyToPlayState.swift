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

import Stateful

struct ReadyToPlayState: State, Effectful {

    var isPlaying: Bool
    var currentTime: TimeInterval? // This should not be optional
    var info: Player.Info

    var nextState: State?
    let world = World.shared

    static let seekInterval: TimeInterval = 15

    init(isPlaying: Bool, currentTime: TimeInterval?, info: Player.Info) {
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.info = info
    }

}

extension ReadyToPlayState: Presentable {

    func present() -> View {
        return AudioBarView(
            playPauseButtonImage: playPauseButtonImage,
            isPlayPauseButtonEnabled: isPlayPauseButtonEnabled,
            areSeekButtonsHidden: false,
            playbackTime: remainingTimeText,
            isSeekBackButtonEnabled: isSeekBackButtonEnabled,
            isSeekForwardButtonEnabled: isSeekForwardButtonEnabled,
            isLoadingIndicatorVisible: isPlaying && currentTime == nil,
            isPlayCommandEnabled: !isPlaying && isPlayPauseButtonEnabled,
            isPauseCommandEnabled: isPlaying && isPlayPauseButtonEnabled,
            seekInterval: ReadyToPlayState.seekInterval,
            playbackDuration: info.duration,
            elapsedPlaybackTime: currentTime ?? 0,
            trackName: info.title,
            artistName: info.artist,
            albumName: info.album,
            artworkData: info.artwork
        )
    }

    private var playPauseButtonImage: AudioBarView.PlayPauseButtonImage {
        return isPlaying ? .pause : .play
    }

    private var remainingTime: TimeInterval? {
        guard let currentTime = currentTime else {
            return nil
        }
        return info.duration - currentTime
    }

    private var remainingTimeText: String {
        guard let remainingTime = remainingTime else {
            return ""
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return "-" + formatter.string(from: remainingTime)!
    }

    private var isPlayPauseButtonEnabled: Bool {
        guard let remainingTime = remainingTime else {
            return true
        }
        return remainingTime > 0
    }

    private var isSeekBackButtonEnabled: Bool {
        guard let currentTime = currentTime else {
            return false
        }
        return currentTime > 0
    }

    private var isSeekForwardButtonEnabled: Bool {
        guard let remainingTime = remainingTime else {
            return false
        }
        return remainingTime > 0
    }

}

extension ReadyToPlayState {

    public mutating func onPlayerDidUpdateCurrentTime(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
    }

    public mutating func onPlayerDidPlayToEnd() {
        currentTime = info.duration
        isPlaying = false
    }

}

extension ReadyToPlayState {

    public mutating func onUserDidTapPlayButton() throws {
        try world.perform(Player.PlayAction())
        isPlaying = true

    }

    public mutating func onUserDidTapPauseButton() throws {
        try world.perform(Player.PauseAction())
        isPlaying = false
    }

}

extension ReadyToPlayState {

    public mutating func onUserDidTapSeekBackButton() throws {
        currentTime = max(0, currentTime! - ReadyToPlayState.seekInterval)
        try world.perform(Player.SeekAction(currentTime: currentTime!))
    }

    public mutating func onUserDidTapSeekForwardButton() throws {
        currentTime = min(info.duration, currentTime! + ReadyToPlayState.seekInterval)
        try world.perform(Player.SeekAction(currentTime: currentTime!))
    }

}

extension ReadyToPlayState {

    public mutating func reset() throws {
        try world.perform(Player.LoadAction(url: nil))
        nextState = WaitingForURLState()
    }
    
}
