import UIKit
import AVFoundation
import MediaPlayer
import Elm

public final class AudioBarViewController: UIViewController, StoreDelegate {

    private lazy var store: Store<AudioBar> = AudioBar.makeStore(delegate: self, seed: .init())
    private let player = AVPlayer()
    private let volumeView = MPVolumeView()

    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var seekBackButton: UIButton!
    @IBOutlet private var seekForwardButton: UIButton!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var audioRouteView: UIView!

    @IBAction func userDidTapPlayPauseButton() {
        let message = store.view.playPauseButtonEvent
        store.dispatch(.playPauseButton(message))
    }

    @IBAction func userDidTapSeekForwardButton() {
        store.dispatch(.userDidTapSeekForwardButton)
    }

    @IBAction func userDidTapSeekBackButton() {
        store.dispatch(.userDidTapSeekBackButton)
    }

    public func loadURL(url: URL?) {
        store.dispatch(.prepareToLoad(url))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        volumeView.showsVolumeSlider = false
        volumeView.setRouteButtonImage(loadImage(withName: "AirPlay Icon"), for: .normal)
        audioRouteView.addSubview(volumeView)
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: UIFontWeightRegular)
        player.addPeriodicTimeObserver(forInterval: CMTime(timeInterval: 0.1), queue: nil) { [weak player, weak store] time in
            guard player?.currentItem?.status == .readyToPlay else { return }
            guard let currentTime = player?.currentTime().timeInterval else { return }
            store?.dispatch(.playerDidUpdateCurrentTime(currentTime))
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        volumeView.frame = audioRouteView.bounds
    }

    public func store(_ store: Store<AudioBar>, didUpdate view: AudioBar.View) {
        var playPauseButtonImage: UIImage {
            switch view.playPauseButtonEvent {
            case .userDidTapPlayButton: return loadImage(withName: "Play Button")
            case .userDidTapPauseButton: return loadImage(withName: "Pause Button")
            }
        }
        playPauseButton.setImage(playPauseButtonImage, for: .normal)
        playPauseButton.isEnabled = view.isPlayPauseButtonEnabled
        seekBackButton.isHidden = view.areSeekButtonsHidden
        seekBackButton.isEnabled = view.isSeekBackButtonEnabled
        seekForwardButton.isHidden = view.areSeekButtonsHidden
        seekForwardButton.isEnabled = view.isSeekForwardButtonEnabled
        timeLabel.text = view.playbackTime
        loadingIndicator.isHidden = !view.isLoadingIndicatorVisible
    }

    public func store(_ store: Store<AudioBar>, didRequest action: AudioBar.Action) {
        switch action {
        case .player(let action):
            switch action {
            case .loadURL(let url):
                if let playerItem = player.currentItem {
                    player.replaceCurrentItem(with: nil)
                    endObservingPlayerItem(playerItem)
                }
                if let url = url {
                    let playerItem = AVPlayerItem(url: url)
                    beginObservingPlayerItem(playerItem)
                    player.replaceCurrentItem(with: playerItem)
                }
            case .play:
                player.play()
            case .pause:
                player.pause()
            case .setCurrentTime(let time):
                player.seek(to: CMTime(timeInterval: time))
            }
        case .showAlert(text: let text, button: let button):
            let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: button, style: .default, handler: nil))
            present(alertController, animated: true)
        }
    }

    private func beginObservingPlayerItem(_ playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [weak store] _ in
            store?.dispatch(.playerDidPlayToEnd)
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
                store.dispatch(.playerDidBecomeReadyToPlay(withDuration: playerItem.duration.timeInterval))
            case .failed:
                store.dispatch(.playerDidFailToBecomeReady)
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

extension CMTime {

    init(timeInterval: TimeInterval) {
        self = CMTime(seconds: timeInterval, preferredTimescale: 44100)
    }

    var timeInterval: TimeInterval {
        return CMTimeGetSeconds(self)
    }
    
}
