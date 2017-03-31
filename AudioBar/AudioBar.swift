import Foundation
import Stateful

public struct AudioBar: StateMachine {

    public enum Event {

        case prepareToLoad(URL)
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

            // WARNING: Unnecessary optional value
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

        enum PlayPauseButtonImage {
            case play
            case pause
        }

        let playPauseButtonImage: PlayPauseButtonImage
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
                        playPauseButtonImage: .play,
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
                return .mutate(.readyToLoadURL(url))

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
                        playPauseButtonImage: .play,
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

        // MARK: - Waiting for player to load URL

        switch state {

        case .waitingForPlayerToLoad(let url):

            switch trigger {

            case .didMutate:
                return .present(
                    .init(
                        playPauseButtonImage: .pause,
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
                // WARNING: Duplicate(1)
                return .mutate(.waitingForURL)

            default:
                break

            }

            // MARK: + Reset

            switch trigger {

            case .didReceive(.reset):
                return .perform(.player(.load(nil)))

            case .didPerform(.player(.load(nil)), result: _ as Void):
                // WARNING: Duplicate(2)
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
                let playPauseButtonImage: View.PlayPauseButtonImage =
                    readyToPlay.isPlaying
                        ? .pause
                        : .play
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
                        playPauseButtonImage: playPauseButtonImage,
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

            // WARNING: The following MARK conflates 2 events into one

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

}
