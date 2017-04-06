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

struct ReadyToPlayState: State, Effectful {

    var nextState: State? = nil
    let world = World.shared

    static let seekInterval: TimeInterval = 15

}

extension ReadyToPlayState {

    public func onPlayerDidUpdateElapsedPlaybackTime() {}
    public func onPlayerDidPlayToEnd() {}

}

extension ReadyToPlayState {

    public func onUserDidTapPlayButton() {
        world.send(Player.PlayingUpdate(isPlaying: true))
    }

    public func onUserDidTapPauseButton() {
        world.send(Player.PlayingUpdate(isPlaying: false))
    }

    public func onUserDidTapPlayPauseButton() {
        let isPlaying = world.receive(Player.Playing())
        world.send(Player.PlayingUpdate(isPlaying: !isPlaying))
    }

}

extension ReadyToPlayState {

    public func onUserDidTapSeekBackButton() {
        let oldElapsedPlaybackTime = world.receive(Player.ElapsedPlaybackTime())
        let newElapsedPlaybackTime = max(0, oldElapsedPlaybackTime! - ReadyToPlayState.seekInterval)
        world.send(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: newElapsedPlaybackTime))
    }

    public func onUserDidTapSeekForwardButton() {
        let playbackDuration = world.receive(Player.PlaybackDuration())
        let oldElapsedPlaybackTime = world.receive(Player.ElapsedPlaybackTime())
        let newElapsedPlaybackTime = min(playbackDuration, oldElapsedPlaybackTime! + ReadyToPlayState.seekInterval)
        world.send(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: newElapsedPlaybackTime))
    }

}

extension ReadyToPlayState {

    public mutating func reset() {
        world.send(Player.Load(url: nil))
        nextState = WaitingForURLState()
    }
    
}

extension ReadyToPlayState: Presentable {

    func present() -> View {

        let isPlaying = world.receive(Player.Playing())
        let elapsedPlaybackTime = world.receive(Player.ElapsedPlaybackTime())

        var playPauseButtonImage: AudioBarView.PlayPauseButtonImage {
            return isPlaying ? .pause : .play
        }

        var remainingTime: TimeInterval? {
            guard let elapsedPlaybackTime = elapsedPlaybackTime else {
                return nil
            }
            let playbackDuration = world.receive(Player.PlaybackDuration())
            return playbackDuration - elapsedPlaybackTime
        }

        var remainingTimeText: String {
            guard let remainingTime = remainingTime else {
                return ""
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            return "-" + formatter.string(from: remainingTime)!
        }

        var isPlayPauseButtonEnabled: Bool {
            guard let remainingTime = remainingTime else {
                return true
            }
            return remainingTime > 0
        }

        var isSeekBackButtonEnabled: Bool {
            guard let elapsedPlaybackTime = elapsedPlaybackTime else {
                return false
            }
            return elapsedPlaybackTime > 0
        }

        var isSeekForwardButtonEnabled: Bool {
            guard let remainingTime = remainingTime else {
                return false
            }
            return remainingTime > 0
        }

        return AudioBarView(
            playPauseButtonImage: playPauseButtonImage,
            isPlayPauseButtonEnabled: isPlayPauseButtonEnabled,
            areSeekButtonsHidden: false,
            playbackTime: remainingTimeText,
            isSeekBackButtonEnabled: isSeekBackButtonEnabled,
            isSeekForwardButtonEnabled: isSeekForwardButtonEnabled,
            isLoadingIndicatorVisible: isPlaying && elapsedPlaybackTime == nil,
            isPlayCommandEnabled: !isPlaying && isPlayPauseButtonEnabled,
            isPauseCommandEnabled: isPlaying && isPlayPauseButtonEnabled,
            seekInterval: ReadyToPlayState.seekInterval,
            playbackDuration: world.receive(Player.PlaybackDuration()),
            elapsedPlaybackTime: elapsedPlaybackTime ?? 0,
            trackName: world.receive(Player.Metadata.TrackName()),
            artistName: world.receive(Player.Metadata.ArtistName()),
            albumName: world.receive(Player.Metadata.AlbumName()),
            artworkData: world.receive(Player.Metadata.ArtworkData())
        )
    }

}
