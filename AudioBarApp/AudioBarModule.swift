import Foundation
import Elm

struct AudioBarModule: ElmModule {

    //
    // MARK: -
    // MARK: Message
    //

    enum Message {

        case prepareToLoad(URL)
        case togglePlay
        case seekBack
        case seekForward

        case playerDidBecomeReadyToPlay(withDuration: TimeInterval)
        case playerDidFailToBecomeReady
        case playerDidUpdateCurrentTime(TimeInterval)
        case playerDidPlayToEnd

    }

    //
    // MARK: -
    // MARK: Model
    //

    enum Model: Initable {

        struct ReadyState {
            var isPlaying: Bool
            var duration: TimeInterval
            var currentTime: TimeInterval?
        }

        case waitingForURL
        case readyToLoadURL(URL)
        case waitingForPlayerToBecomeReadyToPlayURL(URL)
        case readyToPlay(ReadyState)

        init() { self = .waitingForURL }

    }

    //
    // MARK: -
    // MARK: Command
    //

    enum Command {

        enum Player {
            case loadURL(URL)
            case play
            case pause
            case setCurrentTime(TimeInterval)
            case reset
        }

        case player(Player)
        case showAlert(text: String, button: String)

    }

    //
    // MARK: -
    // MARK: View
    //

    struct View {

        public enum PlayPauseButtonMode { case play, pause }

        let playPauseButtonMode: PlayPauseButtonMode // Rename to match togglePlay
        let isPlayPauseButtonEnabled: Bool
        let areSeekButtonsHidden: Bool
        let playbackTime: String

        let isSeekBackButtonEnabled: Bool
        let isSeekForwardButtonEnabled: Bool

        let isLoadingIndicatorVisible: Bool

    }

    //
    // MARK: -
    // MARK: Update
    //

    static func update(for message: Message, model: inout Model) throws -> [Command] {
        switch message {

        case .prepareToLoad(let url):
            model = .readyToLoadURL(url)
            return []

        case .togglePlay:
            switch model {

            case .waitingForURL:
                throw error

            case .readyToLoadURL(at: let url):
                model = .waitingForPlayerToBecomeReadyToPlayURL(url)
                return [.player(.loadURL(url))]

            case .waitingForPlayerToBecomeReadyToPlayURL(let url):
                model = .readyToLoadURL(url)
                return [.player(.reset)]

            case .readyToPlay(var state):
                let command: Command = .player(state.isPlaying ? .pause : .play)
                state.isPlaying = !state.isPlaying
                model = .readyToPlay(state)
                return [command]
            }

        case .seekBack:
            guard case .readyToPlay(var state) = model else { throw error }
            state.currentTime = max(0, state.currentTime! - 15)
            model = .readyToPlay(state)
            return [.player(.setCurrentTime(state.currentTime!))]

        case .seekForward:
            guard case .readyToPlay(var state) = model else { throw error }
            let currentTime = min(state.duration, state.currentTime! + 15)
            let currentTimeCommand = Command.player(.setCurrentTime(currentTime))
            let shouldPause = currentTime == state.duration && state.isPlaying
            let shouldPauseCommand: Command? = shouldPause ? .player(.pause) : nil
            if shouldPause { state.isPlaying = false }
            let commands = [currentTimeCommand, shouldPauseCommand].flatMap { $0 }
            state.currentTime = currentTime
            model = .readyToPlay(state)
            return commands

        case .playerDidBecomeReadyToPlay(withDuration: let duration):
            guard case .waitingForPlayerToBecomeReadyToPlayURL = model else { throw error }
            model = .readyToPlay(.init(isPlaying: true, duration: duration, currentTime: nil))
            return [.player(.play)]

        case .playerDidPlayToEnd:
            guard case .readyToPlay(var state) = model, state.isPlaying else { throw error }
            state.currentTime = state.duration
            state.isPlaying = false
            model = .readyToPlay(state)
            return []

        case .playerDidUpdateCurrentTime(let currentTime):
            guard case .readyToPlay(var state) = model else { throw error }
            state.currentTime = currentTime
            model = .readyToPlay(state)
            return []

        case .playerDidFailToBecomeReady:
            guard case .waitingForPlayerToBecomeReadyToPlayURL(let url) = model else { throw error }
            model = .readyToLoadURL(url)
            return [.player(.reset), .showAlert(text: "Unable to load media", button: "OK")]

        }
    }

    static func view(for model: Model) -> View {
        switch model {

        case .waitingForURL:
             return View(
                playPauseButtonMode: .play,
                isPlayPauseButtonEnabled: false,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: false
            )

        case .readyToLoadURL:
            return View(
                playPauseButtonMode: .play,
                isPlayPauseButtonEnabled: true,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: false
            )

        case .waitingForPlayerToBecomeReadyToPlayURL:
            return View(
                playPauseButtonMode: .pause,
                isPlayPauseButtonEnabled: true,
                areSeekButtonsHidden: true,
                playbackTime: "",
                isSeekBackButtonEnabled: false,
                isSeekForwardButtonEnabled: false,
                isLoadingIndicatorVisible: true
            )

        case .readyToPlay(let state):
            var remainingTime: TimeInterval? {
                guard let currentTime = state.currentTime else { return nil }
                return state.duration - currentTime
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
                guard let currentTime = state.currentTime else { return false }
                return currentTime > 0
            }
            var isSeekForwardButtonEnabled: Bool {
                guard let remainingTime = remainingTime else { return false }
                return remainingTime > 0
            }
            return View(
                playPauseButtonMode: state.isPlaying ? .pause : .play,
                isPlayPauseButtonEnabled: isPlayPauseButtonEnabled,
                areSeekButtonsHidden: false,
                playbackTime: remainingTimeText,
                isSeekBackButtonEnabled: isSeekBackButtonEnabled,
                isSeekForwardButtonEnabled: isSeekForwardButtonEnabled,
                isLoadingIndicatorVisible: state.isPlaying && state.currentTime == nil
            )

        }
    }

}
