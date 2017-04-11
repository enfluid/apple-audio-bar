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

public struct ReadyToPlayState: State, Effectful {

    public var nextState: State?
    public let world = World.shared

    private var isPlaying: Bool {
        return world.receive(Player.Playing())
    }

    private var remainingTime: TimeInterval? {
        guard elapsedPlaybackTime > 0 else {
            return nil
        }
        let playbackDuration = world.receive(Player.PlaybackDuration())
        return playbackDuration - elapsedPlaybackTime
    }

    // UI

    public var playPauseButtonImage: PlayPauseButtonImage {
        return isPlaying ? .pause : .play
    }

    public var isPlayPauseButtonEnabled: Bool {
        guard let remainingTime = remainingTime else {
            return true
        }
        return remainingTime > 0
    }

    public let areSeekButtonsHidden = false

    public var playbackTime: String {
        guard let remainingTime = remainingTime else {
            return ""
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return "-" + formatter.string(from: remainingTime)!
    }

    public var isSeekBackButtonEnabled: Bool {
        return elapsedPlaybackTime > 0
    }

    public var isSeekForwardButtonEnabled: Bool {
        guard let remainingTime = remainingTime else {
            return false
        }
        return remainingTime > 0
    }

    public var isLoadingIndicatorVisible: Bool {
        return isPlaying && elapsedPlaybackTime == 0
    }

    public var isPlayCommandEnabled: Bool {
        return !isPlaying && isPlayPauseButtonEnabled
    }

    public var isPauseCommandEnabled: Bool {
        return isPlaying && isPlayPauseButtonEnabled
    }

    public let seekInterval: TimeInterval = 15

    public var playbackDuration: TimeInterval {
        return world.receive(Player.PlaybackDuration())
    }

    public var elapsedPlaybackTime: TimeInterval {
        return world.receive(Player.ElapsedPlaybackTime()) ?? 0
    }

    public var trackName: String? {
        return world.receive(Player.Metadata.TrackName())
    }

    public var artistName: String? {
        return world.receive(Player.Metadata.ArtistName())
    }

    public var albumName: String? {
        return world.receive(Player.Metadata.AlbumName())
    }

    public var artworkData: Data? {
        return world.receive(Player.Metadata.ArtworkData())
    }

}

extension ReadyToPlayState {

    public mutating func prepareToLoad(_ url: URL?) {
        world.send(Player.Load(url: nil))
        if let url = url {
            nextState = ReadyToLoadURLState(url: url)
        } else {
            nextState = WaitingForURLState()
        }
    }

}

extension ReadyToPlayState {

    public func onPlayerDidUpdateElapsedPlaybackTime(_ currentTime: TimeInterval) {}
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
        let newElapsedPlaybackTime = max(0, oldElapsedPlaybackTime! - seekInterval)
        world.send(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: newElapsedPlaybackTime))
    }

    public func onUserDidTapSeekForwardButton() {
        let playbackDuration = world.receive(Player.PlaybackDuration())
        let oldElapsedPlaybackTime = world.receive(Player.ElapsedPlaybackTime())
        let newElapsedPlaybackTime = min(playbackDuration, oldElapsedPlaybackTime! + seekInterval)
        world.send(Player.ElapsedPlaybackTimeUpdate(elapsedPlaybackTime: newElapsedPlaybackTime))
    }

}
