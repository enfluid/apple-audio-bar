import MediaPlayer

extension MPNowPlayingInfoCenter {

    func setElapsedPlaybackTime(_ elapsedPlaybackTime: TimeInterval) {
        guard needsSetElapsedPlaybackTime(elapsedPlaybackTime) else { return }
        forceSetElapsedPlaybackTime(elapsedPlaybackTime)
    }

    private func needsSetElapsedPlaybackTime(_ elapsedPlaybackTime: TimeInterval) -> Bool {
        return nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval != elapsedPlaybackTime
    }

    private func forceSetElapsedPlaybackTime(_ elapsedPlaybackTime: TimeInterval) {
        nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
    }

}
