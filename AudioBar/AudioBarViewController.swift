import UIKit
import AVFoundation
import MediaPlayer
import Stateful
import AudioBarCore

public final class AudioBarViewController: UIViewController, StoreDelegate {

    private lazy var store: Store = .init(initialState: WaitingForURLState())

    public func store(_ store: Store, didOutput view: View) {
        fatalError()
    }

    public func store(_ store: Store, didSend output: Output) {
        fatalError()
    }

    public func store<InputType>(_ store: Store, willReceive input: InputType) -> InputType.Payload where InputType : Input {
        fatalError()
    }

    private let player = AVPlayer()
    private let volumeView = MPVolumeView()
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var seekBackButton: UIButton!
    @IBOutlet private var seekForwardButton: UIButton!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var audioRouteView: UIView!

    @IBAction private func userDidTapPlayPauseButton() {
        store.perform { state in
            switch state {
            case var nextState as ReadyToLoadURLState:
                nextState.onUserDidTapPlayPauseButton()
                state = nextState
            case var nextState as WaitingForPlayerToLoadState:
                nextState.onUserDidTapPlayPauseButton()
                state = nextState
            case let nextState as ReadyToPlayState:
                nextState.onUserDidTapPlayPauseButton()
            default:
                fatalError()
            }
        }
    }

    @IBAction private func userDidTapSeekForwardButton() {
        store.perform { state in
            let nextState = state as! ReadyToPlayState
            nextState.onUserDidTapSeekForwardButton()
        }
    }

    @IBAction private func userDidTapSeekBackButton() {
        store.perform { state in
            let nextState = state as! ReadyToPlayState
            nextState.onUserDidTapSeekBackButton()
        }
    }

    public func loadURL(url: URL) {
        store.perform { state in
            switch state {
            case var nextState as WaitingForURLState:
                nextState.prepareToLoad(url)
                state = nextState
            case var nextState as ReadyToLoadURLState:
                nextState.prepareToLoad(url)
                state = nextState
            case var nextState as WaitingForPlayerToLoadState:
                nextState.prepareToLoad(url)
                state = nextState
            case var nextState as ReadyToPlayState:
                nextState.prepareToLoad(url)
                state = nextState
            default:
                fatalError()
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureCommandCenterCommands()
        volumeView.showsVolumeSlider = false
        volumeView.setRouteButtonImage(loadImage(withName: "AirPlay Icon"), for: .normal)
        audioRouteView.addSubview(volumeView)
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: UIFontWeightRegular)
        player.addPeriodicTimeObserver(forInterval: CMTime(timeInterval: 0.1), queue: nil) { [weak player, weak store] _ in
            guard player?.currentItem?.status == .readyToPlay else { return }
            guard let currentTime = player?.currentTime().timeInterval else { return }
            store?.perform { state in
                let nextState = state as! ReadyToPlayState
                nextState.onPlayerDidUpdateElapsedPlaybackTime(currentTime)
            }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        volumeView.frame = audioRouteView.bounds
    }

//    public func stateControllerDidUpdate(_ view: AudioBar.View) {
//
//        var playPauseButtonImage: UIImage {
//            switch view.playPauseButtonImage {
//            case .play:
//                return loadImage(withName: "Play Button")
//            case .pause:
//                return loadImage(withName: "Pause Button")
//            }
//        }
//
//        playPauseButton.setImage(playPauseButtonImage, for: .normal)
//        playPauseButton.isEnabled = view.isPlayPauseButtonEnabled
//
//        seekBackButton.isHidden = view.areSeekButtonsHidden
//        seekBackButton.isEnabled = view.isSeekBackButtonEnabled
//
//        seekForwardButton.isHidden = view.areSeekButtonsHidden
//        seekForwardButton.isEnabled = view.isSeekForwardButtonEnabled
//
//        timeLabel.text = view.playbackTime
//
//        loadingIndicator.isHidden = !view.isLoadingIndicatorVisible
//
//        remoteCommandCenter.togglePlayPauseCommand.isEnabled = view.isPlayPauseButtonEnabled
//        remoteCommandCenter.playCommand.isEnabled = view.isPlayCommandEnabled
//        remoteCommandCenter.pauseCommand.isEnabled = view.isPauseCommandEnabled
//        remoteCommandCenter.skipForwardCommand.isEnabled = view.isSeekForwardButtonEnabled
//        remoteCommandCenter.skipBackwardCommand.isEnabled = view.isSeekBackButtonEnabled
//        remoteCommandCenter.skipForwardCommand.preferredIntervals = [.init(value: view.seekInterval)]
//        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [.init(value: view.seekInterval)]
//
//        var nowPlayingInfo: [String: Any] = [:]
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = view.playbackDuration
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = view.elapsedPlaybackTime
//        if let trackName = view.trackName {
//            nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
//        }
//        if let artistName = view.artistName {
//            nowPlayingInfo[MPMediaItemPropertyArtist] = artistName
//        }
//        if let albumName = view.albumName {
//            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = albumName
//        }
//        if let artworkData = view.artworkData, let artwork = UIImage(data: artworkData) {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: artwork)
//        }
//        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
//
//    }

//    public func stateControllerDidRequest(_ action: AudioBar.Action) -> Any {
//
//        switch action {
//
//        case .player(let action):
//
//            switch action {
//
//            case .load(let url):
//                if let playerItem = player.currentItem {
//                    player.replaceCurrentItem(with: nil)
//                    endObservingPlayerItem(playerItem)
//                }
//                if let url = url {
//                    let playerItem = AVPlayerItem(url: url)
//                    beginObservingPlayerItem(playerItem)
//                    player.replaceCurrentItem(with: playerItem)
//                }
//                return Void()
//
//            case .getInfo:
//                let playerItem = player.currentItem!
//                let metadata = playerItem.asset.metadata
//                return AudioBar.Action.Player.Info(
//                    title: metadata.title,
//                    artist: metadata.artist,
//                    album: metadata.album,
//                    artwork: metadata.artwork,
//                    duration: playerItem.duration.timeInterval
//                )
//
//            case .play:
//                player.play()
//                return Void()
//
//            case .pause:
//                player.pause()
//                return Void()
//
//            case .setCurrentTime(let time):
//                player.seek(to: CMTime(timeInterval: time))
//                return Void()
//
//            }
//
//        case .showAlert(text: let text, button: let button):
//            let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: button, style: .default, handler: nil))
//            present(alertController, animated: true)
//            return Void()
//
//        }
//
//    }

    private func configureCommandCenterCommands() {
        let view = store.view as! AudioBarView
        remoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard view.isPlayPauseButtonEnabled else { return .commandFailed }
            self!.userDidTapPlayPauseButton()
            return .success
        }
        remoteCommandCenter.playCommand.addTarget { [weak store] _ in
            guard view.isPlayCommandEnabled else { return .commandFailed }
            store!.perform { state in
                switch state {
                case var nextState as ReadyToLoadURLState:
                    nextState.onUserDidTapPlayButton()
                    state = nextState
                case let nextState as ReadyToPlayState:
                    nextState.onUserDidTapPlayButton()
                default:
                    fatalError()
                }
            }
            return .success
        }
        remoteCommandCenter.pauseCommand.addTarget { [weak store] _ in
            guard view.isPauseCommandEnabled else { return .commandFailed }
            store!.perform { state in
                switch state {
                case var nextState as WaitingForPlayerToLoadState:
                    nextState.onUserDidTapPauseButton()
                    state = nextState
                case let nextState as ReadyToPlayState:
                    nextState.onUserDidTapPauseButton()
                default:
                    fatalError()
                }
            }
            return .success
        }
        remoteCommandCenter.skipForwardCommand.addTarget { [weak store] _ in
            guard view.isSeekForwardButtonEnabled else { return .commandFailed }
            store!.perform { state in
                let nextState = state as! ReadyToPlayState
                nextState.onUserDidTapSeekForwardButton()
            }
            return .success
        }
        remoteCommandCenter.skipBackwardCommand.addTarget { [weak store] _ in
            guard view.isSeekBackButtonEnabled else { return .commandFailed }
            store!.perform { state in
                let nextState = state as! ReadyToPlayState
                nextState.onUserDidTapSeekBackButton()
            }
            return .success
        }
    }

    private func beginObservingPlayerItem(_ playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    @objc private func playerDidPlayToEnd() {
        store.perform { state in
            let nextState = state as! ReadyToPlayState
            nextState.onPlayerDidPlayToEnd()
        }
    }

    private func endObservingPlayerItem(_ playerItem: AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = player.currentItem, object as? AVPlayerItem == playerItem, keyPath == #keyPath(AVPlayerItem.status) {
            guard change![.oldKey] as! NSValue != change![.newKey] as! NSValue else { return }
            switch playerItem.status {
            case .unknown:
                break
            case .readyToPlay:
                store.perform { state in
                    var nextState = state as! WaitingForPlayerToLoadState
                    nextState.onPlayerDidBecomeReady()
                    state = nextState
                }
            case .failed:
                store.perform { state in
                    var nextState = state as! WaitingForPlayerToLoadState
                    nextState.onPlayerDidFailToBecomeReady()
                    state = nextState
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    public static func instantiateFromStoryboard() -> AudioBarViewController {
        let storyboard = UIStoryboard(name: "AudioBar", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! AudioBarViewController
    }

    private func loadImage(withName name: String) -> UIImage {
        return UIImage(named: name, in: AudioBarViewController.bundle, compatibleWith: traitCollection)!
    }

    private static var bundle: Bundle {
        return Bundle(for: AudioBarViewController.self)
    }

}
