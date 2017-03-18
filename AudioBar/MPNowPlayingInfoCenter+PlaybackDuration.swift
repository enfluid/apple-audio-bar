import MediaPlayer

extension MPNowPlayingInfoCenter {

    func setPlaybackDuration(_ playbackDuration: TimeInterval) {
        guard needsSetPlaybackDuration(playbackDuration) else { return }
        forceSetPlaybackDuration(playbackDuration)
    }

    private func needsSetPlaybackDuration(_ playbackDuration: TimeInterval) -> Bool {
        return nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval != playbackDuration
    }

    private func forceSetPlaybackDuration(_ playbackDuration: TimeInterval) {
        nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = playbackDuration
    }

}
