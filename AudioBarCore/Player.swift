import Stateful

struct Player {

    struct PlayAction: Action {
    }

    struct PauseAction: Action {
    }

    struct GetInfoAction: Action {
        struct Output {
            var title: String?
            var artist: String?
            var album: String?
            var artwork: Data?
            let duration: TimeInterval
        }
    }

    struct LoadAction: Action {
        let url: URL?
    }

    struct SeekAction: Action {
        let currentTime: TimeInterval
    }
    
}
