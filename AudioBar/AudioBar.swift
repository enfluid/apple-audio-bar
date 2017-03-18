import Foundation
import Elm

public struct AudioBar: Program {

    public struct Seed {}

    public enum Event {
        public enum PlayPauseButton {
            case userDidTapPlayButton
            case userDidTapPauseButton
        }
        case prepareToLoad(URL?)
        case playPauseButton(PlayPauseButton)
        case userDidTapSeekBackButton
        case userDidTapSeekForwardButton
        case playerDidBecomeReadyToPlay(withDuration: TimeInterval)
        case playerDidFailToBecomeReady
        case playerDidUpdateCurrentTime(TimeInterval)
        case playerDidPlayToEnd
    }

    public enum State {
        public struct ReadyToPlay {
            var isPlaying: Bool
            var duration: TimeInterval
            var currentTime: TimeInterval?
        }
        case waitingForURL
        case readyToLoadURL(URL)
        case waitingForPlayerToBecomeReadyToPlayURL(URL)
        case readyToPlay(ReadyToPlay)
        static let seekInterval: TimeInterval = 15
    }

    public enum Action {
        public enum Player {
            case loadURL(URL?)
            case play
            case pause
            case setCurrentTime(TimeInterval)
        }
        case player(Player)
        case showAlert(text: String, button: String)
    }

    public struct View {
        let playPauseButtonEvent: Event.PlayPauseButton
        let isPlayPauseButtonEnabled: Bool
        let areSeekButtonsHidden: Bool
        let playbackTime: String
        let isSeekBackButtonEnabled: Bool
        let isSeekForwardButtonEnabled: Bool
        let isLoadingIndicatorVisible: Bool
        let isPlayCommandEnabled: Bool
        let isPauseCommandEnabled: Bool
        let seekInterval: TimeInterval
        let playbackDuration: TimeInterval
        let elapsedPlaybackTime: TimeInterval
    }

    public enum Failure: Error {
        case noURL
        case readyToLoadURL
        case notReadyToPlay
        case playing
        case notPlaying
        case waitingToBecomeReadyToPlay
        case notWaitingToBecomeReadyToPlay
    }

    public static func start(with seed: Seed, perform: (Action) -> Void) -> Result<State, Failure> {
        let state = State.waitingForURL
        return .success(state)
    }

    public static func update(for event: Event, state: inout State, perform: (Action) -> Void) -> Result<Success, Failure> {
        switch event {
        case .prepareToLoad(let url):
            let isPlayerActive: Bool = {
                switch state {
                case .waitingForURL:
                    return false
                case .readyToLoadURL:
                    return false
                case .waitingForPlayerToBecomeReadyToPlayURL:
                    return true
                case .readyToPlay:
                    return true
                }
            }()
            if isPlayerActive {
                perform(.player(.loadURL(nil)))
            }
            if let url = url {
                state = .readyToLoadURL(url)
            } else {
                state = .waitingForURL
            }
        case .playPauseButton(.userDidTapPlayButton):
            switch state {
            case .waitingForURL:
                return .failure(.noURL)
            case .readyToLoadURL(at: let url):
                state = .waitingForPlayerToBecomeReadyToPlayURL(url)
                perform(.player(.loadURL(url)))
            case .waitingForPlayerToBecomeReadyToPlayURL:
                return .failure(.waitingToBecomeReadyToPlay)
            case .readyToPlay(var readyToPlay):
                guard !readyToPlay.isPlaying else { return .failure(.playing) }
                readyToPlay.isPlaying = true
                state = .readyToPlay(readyToPlay)
                perform(.player(.play))
            }
        case .playPauseButton(.userDidTapPauseButton):
            switch state {
            case .waitingForURL:
                return .failure(.noURL)
            case .readyToLoadURL:
                return .failure(.readyToLoadURL)
            case .waitingForPlayerToBecomeReadyToPlayURL(let url):
                state = .readyToLoadURL(url)
                perform(.player(.loadURL(nil)))
            case .readyToPlay(var readyToPlay):
                guard readyToPlay.isPlaying else { return .failure(.notPlaying) }
                readyToPlay.isPlaying = false
                state = .readyToPlay(readyToPlay)
                perform(.player(.pause))
            }
        case .userDidTapSeekBackButton:
            guard case .readyToPlay(var readyToPlay) = state else {
                return .failure(.notReadyToPlay)
            }
            readyToPlay.currentTime = max(0, readyToPlay.currentTime! - State.seekInterval)
            state = .readyToPlay(readyToPlay)
            perform(.player(.setCurrentTime(readyToPlay.currentTime!)))
        case .userDidTapSeekForwardButton:
            guard case .readyToPlay(var readyToPlay) = state else {
                return .failure(.notReadyToPlay)
            }

            let currentTime = min(readyToPlay.duration, readyToPlay.currentTime! + State.seekInterval)
            readyToPlay.currentTime = currentTime
            perform(.player(.setCurrentTime(currentTime)))

            if currentTime == readyToPlay.duration && readyToPlay.isPlaying {
                readyToPlay.isPlaying = false
                perform(.player(.pause))
            }

            state = .readyToPlay(readyToPlay)
        case .playerDidBecomeReadyToPlay(withDuration: let duration):
            guard case .waitingForPlayerToBecomeReadyToPlayURL = state else {
                return .failure(.notWaitingToBecomeReadyToPlay)
            }
            state = .readyToPlay(.init(isPlaying: true, duration: duration, currentTime: nil))
            perform(.player(.play))

        case .playerDidPlayToEnd:
            guard case .readyToPlay(var readyToPlay) = state else {
                return .failure(.notReadyToPlay)
            }
            guard readyToPlay.isPlaying else {
                return .failure(.notPlaying)
            }
            readyToPlay.currentTime = readyToPlay.duration
            readyToPlay.isPlaying = false
            state = .readyToPlay(readyToPlay)
        case .playerDidUpdateCurrentTime(let currentTime):
            guard case .readyToPlay(var readyToPlay) = state else {
                return .failure(.notReadyToPlay)
            }
            readyToPlay.currentTime = currentTime
            state = .readyToPlay(readyToPlay)
        case .playerDidFailToBecomeReady:
            guard case .waitingForPlayerToBecomeReadyToPlayURL(let url) = state else {
                return .failure(.notWaitingToBecomeReadyToPlay)
            }
            state = .readyToLoadURL(url)
            perform(.showAlert(text: "Unable to load media", button: "OK"))
        }
        return .success()
    }

    public static func view(for state: State) -> Result<View, Failure> {
        let view: View
        switch state {
        case .waitingForURL:
            view = .init(
                playPauseButtonEvent: .userDidTapPlayButton,
                isPlayPauseButtonEnabled: false,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: false,
                isPlayCommandEnabled: false,
                isPauseCommandEnabled: false,
                seekInterval: State.seekInterval,
                playbackDuration: 0,
                elapsedPlaybackTime: 0
            )
        case .readyToLoadURL:
            view = .init(
                playPauseButtonEvent: .userDidTapPlayButton,
                isPlayPauseButtonEnabled: true,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: false,
                isPlayCommandEnabled: true,
                isPauseCommandEnabled: false,
                seekInterval: State.seekInterval,
                playbackDuration: 0,
                elapsedPlaybackTime: 0
            )
        case .waitingForPlayerToBecomeReadyToPlayURL:
            view = .init(
                playPauseButtonEvent: .userDidTapPauseButton,
                isPlayPauseButtonEnabled: true,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: true,
                isPlayCommandEnabled: false,
                isPauseCommandEnabled: true,
                seekInterval: State.seekInterval,
                playbackDuration: 0,
                elapsedPlaybackTime: 0
            )
        case .readyToPlay(let readyToPlay):
            var remainingTime: TimeInterval? {
                guard let currentTime = readyToPlay.currentTime else { return nil }
                return readyToPlay.duration - currentTime
            }
            var remainingTimeText: String {
                guard let remainingTime = remainingTime else { return "" }
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.zeroFormattingBehavior = .pad
                return "-" + formatter.string(from: remainingTime)!
            }
            var isPlayPauseButtonEnabled: Bool {
                guard let remainingTime = remainingTime else { return true }
                return remainingTime > 0
            }
            var isSeekBackButtonEnabled: Bool {
                guard let currentTime = readyToPlay.currentTime else { return false }
                return currentTime > 0
            }
            var isSeekForwardButtonEnabled: Bool {
                guard let remainingTime = remainingTime else { return false }
                return remainingTime > 0
            }
            view = .init(
                playPauseButtonEvent: readyToPlay.isPlaying ? .userDidTapPauseButton : .userDidTapPlayButton,
                isPlayPauseButtonEnabled: isPlayPauseButtonEnabled,
                areSeekButtonsHidden: false,
                playbackTime: remainingTimeText,
                isSeekBackButtonEnabled: isSeekBackButtonEnabled,
                isSeekForwardButtonEnabled: isSeekForwardButtonEnabled,
                isLoadingIndicatorVisible: readyToPlay.isPlaying && readyToPlay.currentTime == nil,
                isPlayCommandEnabled: !readyToPlay.isPlaying && isPlayPauseButtonEnabled,
                isPauseCommandEnabled: readyToPlay.isPlaying && isPlayPauseButtonEnabled,
                seekInterval: State.seekInterval,
                playbackDuration: readyToPlay.duration,
                elapsedPlaybackTime: readyToPlay.currentTime ?? 0
            )
        }
        return .success(view)
    }

}
