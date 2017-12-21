import AVFoundation

public struct AudioTags {

    let title: String?
    let artistName: String?
    let albumName: String?
    let artworkData: Data?

    init(commonMetadata: [AVMetadataItem]) {

        func metadataItem(forKey key: String) -> AVMetadataItem? {
            for item in commonMetadata where item.commonKey?.rawValue == key {
                return item
            }
            return nil
        }

        title = metadataItem(forKey: AVMetadataKey.commonKeyTitle.rawValue)?.stringValue
        artistName = metadataItem(forKey: AVMetadataKey.commonKeyArtist.rawValue)?.stringValue
        albumName = metadataItem(forKey: AVMetadataKey.commonKeyAlbumName.rawValue)?.stringValue
        artworkData = metadataItem(forKey: AVMetadataKey.commonKeyArtwork.rawValue)?.dataValue

    }

}
