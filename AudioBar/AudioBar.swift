import Foundation
import Stateful

public struct AudioBar: StateMachine {

    public enum Event {

        case prepareToLoad(URL?)
        case reset

        case userDidTapPlayButton
        case userDidTapPlayPauseButton
        case userDidTapPauseButton
        case userDidTapSeekBackButton
        case userDidTapSeekForwardButton

        case playerDidBecomeReady
        case playerDidFailToBecomeReady
        case playerDidUpdateCurrentTime(TimeInterval)
        case playerDidPlayToEnd

    }

    public enum State {

        public struct ReadyToPlay {

            var isPlaying: Bool
            var currentTime: TimeInterval?
            var info: Action.Player.Info

        }

        case waitingForURL
        case readyToLoadURL(URL)
        case waitingForPlayerToLoad(URL)
        case readyToPlay(ReadyToPlay)

        static let seekInterval: TimeInterval = 15

    }

    public enum Action {

        public enum Player {

            struct Info {
                var title: String?
                var artist: String?
                var album: String?
                var artwork: Data?
                let duration: TimeInterval
            }

            case load(URL?)
            case getInfo
            case play
            case pause
            case setCurrentTime(TimeInterval)

        }

        case player(Player)
        case showAlert(text: String, button: String)

    }

    public struct View {

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
        let trackName: String?
        let artistName: String?
        let albumName: String?
        let artworkData: Data?

    }

    public enum Error {

        case invalidStateTransition // Not tested

    }

    public static var initialState: State {

        return .waitingForURL

    }

    public static func update(_ state: State, trigger: Trigger<AudioBar>) -> Update<AudioBar> {

        // MARK: - Waiting for URL

        switch state {

        case .waitingForURL:

            switch trigger {

            case .didMutate:
                return .present(
                    .init(
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
                        elapsedPlaybackTime: 0,
                        trackName: nil,
                        artistName: nil,
                        albumName: nil,
                        artworkData: nil
                    )
                )

            case .didPresent:
                return .idle

            default:
                break

            }

            // MARK: + Prepare to load URL

            switch trigger {

            case .didReceive(.prepareToLoad(let url)):
                if let url = url {
                    return .mutate(.readyToLoadURL(url))
                } else {
                    return .mutate(.waitingForURL) // This basically can be idle
                }

            default:
                break

            }

            // MARK: + Reset

            switch trigger {

            case .didReceive(.reset):
                return .idle

            default:
                break

            }

        default:
            break

        }

        // MARK: - Ready to load URL

        switch state {

        case .readyToLoadURL(let url):

            switch trigger {

            case .didMutate:
                return .present(
                    .init(
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
                        elapsedPlaybackTime: 0,
                        trackName: nil,
                        artistName: nil,
                        albumName: nil,
                        artworkData: nil
                    )
                )

            case .didPresent:
                return .idle

            default:
                break

            }

            // MARK: + User did tap play/pause button

            switch trigger {

            case .didReceive(.userDidTapPlayButton), .didReceive(.userDidTapPlayPauseButton):
                return .perform(.player(.load(url)))

            case .didPerform(.player(.load(.some(url))), result: _ as Void):
                return .mutate(.waitingForPlayerToLoad(url))

            default:
                break

            }

            // MARK: + Reset

            switch trigger {

            case .didReceive(.reset):
                return .mutate(.waitingForURL)

            default:
                break

            }

        default:
            break

        }

        // MARK: - Waiting for player to load

        switch state {

        case .waitingForPlayerToLoad(let url):

            switch trigger {

            case .didMutate:
                return .present(
                    .init(
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
                        elapsedPlaybackTime: 0,
                        trackName: nil,
                        artistName: nil,
                        albumName: nil,
                        artworkData: nil
                    )
                )

            case .didPresent:
                return .idle

            default:
                break

            }

            // MARK: + Player did become ready

            switch trigger {

            case .didReceive(.playerDidBecomeReady):
                // return .mutate(preparing(.startingPlayback))
                return .perform(.player(.play))

            case .didPerform(.player(.play), result: _ as Void):
                return .perform(.player(.getInfo))

            case .didPerform(.player(.getInfo), result: let info as Action.Player.Info):
                return .mutate(.readyToPlay(.init(isPlaying: true, currentTime: nil, info: info)))

            default:
                break

            }

            // MARK: + Player did fail to become ready

            switch trigger {

            case .didReceive(.playerDidFailToBecomeReady):
                return .perform(.showAlert(text: "Unable to load media", button: "OK"))

            case .didPerform(.showAlert(text: "Unable to load media", button: "OK"), result: _ as Void):
                return .mutate(.readyToLoadURL(url))

            default:
                break

            }

            // MARK: + User did tap play/pause button

            switch trigger {

            case .didReceive(.userDidTapPlayPauseButton):
                return .perform(.player(.load(nil)))

            case .didReceive(.userDidTapPauseButton):
                return .perform(.player(.load(nil)))

            case .didPerform(.player(.load(nil)), result: _ as Void):
                // TODO: Duplicate(1)
                return .mutate(.waitingForURL)

            default:
                break

            }

            // MARK: + Reset

            switch trigger {

            case .didReceive(.reset):
                return .perform(.player(.load(nil)))

            case .didPerform(.player(.load(nil)), result: _ as Void):
                // TODO: Duplicate(2)
                return .mutate(.waitingForURL)

            default:
                break

            }

        default:
            break

        }

        // MARK: - Ready to play

        switch state {

        case .readyToPlay(let readyToPlay):

            switch trigger {

            case .didMutate:
                var remainingTime: TimeInterval? {
                    guard let currentTime = readyToPlay.currentTime else {
                        return nil
                    }
                    return readyToPlay.info.duration - currentTime
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
                    guard let currentTime = readyToPlay.currentTime else {
                        return false
                    }
                    return currentTime > 0
                }
                var isSeekForwardButtonEnabled: Bool {
                    guard let remainingTime = remainingTime else {
                        return false
                    }
                    return remainingTime > 0
                }
                return .present(
                    .init(
                        isPlayPauseButtonEnabled: isPlayPauseButtonEnabled,
                        areSeekButtonsHidden: false,
                        playbackTime: remainingTimeText,
                        isSeekBackButtonEnabled: isSeekBackButtonEnabled,
                        isSeekForwardButtonEnabled: isSeekForwardButtonEnabled,
                        isLoadingIndicatorVisible: readyToPlay.isPlaying && readyToPlay.currentTime == nil,
                        isPlayCommandEnabled: !readyToPlay.isPlaying && isPlayPauseButtonEnabled,
                        isPauseCommandEnabled: readyToPlay.isPlaying && isPlayPauseButtonEnabled,
                        seekInterval: State.seekInterval,
                        playbackDuration: readyToPlay.info.duration,
                        elapsedPlaybackTime: readyToPlay.currentTime ?? 0,
                        trackName: readyToPlay.info.title,
                        artistName: readyToPlay.info.artist,
                        albumName: readyToPlay.info.album,
                        artworkData: readyToPlay.info.artwork
                    )
                )

            case .didPresent:
                return .idle

            default:
                break

            }

            // MARK: + Player did update current time

            switch trigger {

            case .didReceive(.playerDidUpdateCurrentTime(let currentTime)):
                var readyToPlay = readyToPlay
                readyToPlay.currentTime = currentTime
                return .mutate(.readyToPlay(readyToPlay))

            case .didReceive(.playerDidPlayToEnd):
                var readyToPlay = readyToPlay
                readyToPlay.currentTime = readyToPlay.info.duration
                readyToPlay.isPlaying = false
                return .mutate(.readyToPlay(readyToPlay))

            default:
                break

            }

            // MARK: + User did tap play/pause button

            switch trigger {

            case .didReceive(.userDidTapPlayPauseButton):
                let action: Action = readyToPlay.isPlaying
                    ? .player(.pause)
                    : .player(.play)
                return .perform(action)

            case .didReceive(.userDidTapPlayButton):
                return .perform(.player(.play))

            case .didReceive(.userDidTapPauseButton):
                return .perform(.player(.pause))

            case .didPerform(.player(.play), result: _ as Void):
                var readyToPlay = readyToPlay
                readyToPlay.isPlaying = true
                return .mutate(.readyToPlay(readyToPlay))

            case .didPerform(.player(.pause), result: _ as Void):
                var readyToPlay = readyToPlay
                readyToPlay.isPlaying = false
                return .mutate(.readyToPlay(readyToPlay))

            default:
                break
                
            }

            // MARK: + User did tap seek back/forward button

            switch trigger {

            case .didReceive(.userDidTapSeekBackButton):
                // Get rid of 'currentTime' optional
                let currentTime = max(0, readyToPlay.currentTime! - State.seekInterval)
                return .perform(.player(.setCurrentTime(currentTime)))

            case .didReceive(.userDidTapSeekForwardButton):
                let currentTime = min(readyToPlay.info.duration, readyToPlay.currentTime! + State.seekInterval)
                return .perform(.player(.setCurrentTime(currentTime)))

            case .didPerform(.player(.setCurrentTime(let currentTime)), result: _ as Void):
                var readyToPlay = readyToPlay
                readyToPlay.currentTime = currentTime
                return .mutate(.readyToPlay(readyToPlay))

            default:
                break

            }

            // MARK: + Reset

            switch trigger {

            case .didReceive(.reset):
                return .perform(.player(.load(nil)))

            case .didPerform(.player(.load(nil)), result: _ as Void):
                return .mutate(.waitingForURL)

            default:
                break

            }

        default:
            break

        }

        return .raise(.invalidStateTransition)

    }

    //        switch event {
    //        case .prepareToLoad(let url):
    //            let isPlayerActive: Bool = {
    //                switch state {
    //                case .waitingForURL:
    //                    return false
    //                case .readyToLoadURL:
    //                    return false
    //                case .waitingForPlayerToBecomeReadyToPlayURL:
    //                    return true
    //                case .readyToPlay:
    //                    return true
    //                }
    //            }()
    //            if isPlayerActive {
    //                perform(.player(.loadURL(nil)))
    //            }
    //            if let url = url {
    //                state = .readyToLoadURL(url)
    //            } else {
    //                state = .waitingForURL
    //            }
    //        case .playPauseButton(.userDidTapPlayButton):
    //            switch state {
    //            case .waitingForURL:
    //                return .failure(.noURL)
    //            case .readyToLoadURL(at: let url):
    //                state = .waitingForPlayerToBecomeReadyToPlayURL(url)
    //                perform(.player(.loadURL(url)))
    //            case .waitingForPlayerToBecomeReadyToPlayURL:
    //                return .failure(.waitingToBecomeReadyToPlay)
    //            case .readyToPlay(var readyToPlay):
    //                guard !readyToPlay.isPlaying else { return .failure(.playing) }
    //                readyToPlay.isPlaying = true
    //                state = .readyToPlay(readyToPlay)
    //                perform(.player(.play))
    //            }
    //        case .playPauseButton(.userDidTapPauseButton):
    //            switch state {
    //            case .waitingForURL:
    //                return .failure(.noURL)
    //            case .readyToLoadURL:
    //                return .failure(.readyToLoadURL)
    //            case .waitingForPlayerToBecomeReadyToPlayURL(let url):
    //                state = .readyToLoadURL(url)
    //                perform(.player(.loadURL(nil)))
    //            case .readyToPlay(var readyToPlay):
    //                guard readyToPlay.isPlaying else { return .failure(.notPlaying) }
    //                readyToPlay.isPlaying = false
    //                state = .readyToPlay(readyToPlay)
    //                perform(.player(.pause))
    //            }
    //        case .userDidTapSeekBackButton:
    //            guard case .readyToPlay(var readyToPlay) = state else {
    //                return .failure(.notReadyToPlay)
    //            }
    //            readyToPlay.currentTime = max(0, readyToPlay.currentTime! - State.seekInterval)
    //            state = .readyToPlay(readyToPlay)
    //            perform(.player(.setCurrentTime(readyToPlay.currentTime!)))
    //        case .userDidTapSeekForwardButton:
    //            guard case .readyToPlay(var readyToPlay) = state else {
    //                return .failure(.notReadyToPlay)
    //            }
    //
    //            let currentTime = min(readyToPlay.duration, readyToPlay.currentTime! + State.seekInterval)
    //            readyToPlay.currentTime = currentTime
    //            perform(.player(.setCurrentTime(currentTime)))
    //
    //            if currentTime == readyToPlay.duration && readyToPlay.isPlaying {
    //                readyToPlay.isPlaying = false
    //                perform(.player(.pause))
    //            }
    //
    //            state = .readyToPlay(readyToPlay)
    //        case .playerDidBecomeReady(withDuration: let duration, and: let audioTags):
    //            guard case .waitingForPlayerToBecomeReadyToPlayURL = state else {
    //                return .failure(.notWaitingToBecomeReadyToPlay)
    //            }
    //            state = .readyToPlay(.init(isPlaying: true, duration: duration, currentTime: nil, audioTags: audioTags))
    //            perform(.player(.play))
    //
    //        case .playerDidPlayToEnd:
    //            guard case .readyToPlay(var readyToPlay) = state else {
    //                return .failure(.notReadyToPlay)
    //            }
    //            guard readyToPlay.isPlaying else {
    //                return .failure(.notPlaying)
    //            }
    //            readyToPlay.currentTime = readyToPlay.duration
    //            readyToPlay.isPlaying = false
    //            state = .readyToPlay(readyToPlay)
    //        case .playerDidUpdateCurrentTime(let currentTime):
    //            guard case .readyToPlay(var readyToPlay) = state else {
    //                return .failure(.notReadyToPlay)
    //            }
    //            readyToPlay.currentTime = currentTime
    //            state = .readyToPlay(readyToPlay)
    //        case .playerDidFailToBecomeReady:
    //            guard case .waitingForPlayerToBecomeReadyToPlayURL(let url) = state else {
    //                return .failure(.notWaitingToBecomeReadyToPlay)
    //            }
    //            state = .readyToLoadURL(url)
    //            perform(.showAlert(text: "Unable to load media", button: "OK"))
    //        }
    //        return .success()
    //    }

}
