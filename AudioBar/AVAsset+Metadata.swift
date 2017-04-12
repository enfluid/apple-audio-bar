import AVFoundation

extension AVAsset {

    struct Metadata {
        let title: String?
        let artist: String?
        let album: String?
        let artwork: Data?
    }

    var metadata: Metadata {
        return .init(
            title: metadataItem(for: AVMetadataCommonKeyTitle)?.stringValue,
            artist: metadataItem(for: AVMetadataCommonKeyArtist)?.stringValue,
            album: metadataItem(for: AVMetadataCommonKeyAlbumName)?.stringValue,
            artwork: metadataItem(for: AVMetadataCommonKeyArtwork)?.dataValue
        )
    }

    private func metadataItem(for commonKey: String) -> AVMetadataItem? {
        for metadataItem in commonMetadata where metadataItem.commonKey == commonKey {
            return metadataItem
        }
        return nil
    }

}
