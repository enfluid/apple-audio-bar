// The MIT License (MIT)
//
// Copyright (c) 2017 Enfluid
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Stateful

struct Player {

    private init() {}
}

extension Player {

    struct PlayAction: Action {}
    struct PauseAction: Action {}

}

extension Player {

    struct Info: Arbitrary {

        var title: String?
        var artist: String?
        var album: String?
        var artwork: Data?
        let duration: TimeInterval

        static let arbitrary = Player.Info(
            title: "foo",
            artist: "bar",
            album: "baz",
            artwork: Data(),
            duration: 60
        )

    }

    struct GetInfoAction: Action {
        typealias Output = Info
    }

}

extension Player {

    struct LoadAction: Action {
        let url: URL?
    }

}

extension Player {

    struct SeekAction: Action {
        let currentTime: TimeInterval
    }
    
}

extension Player {

    struct GetCurrentTime: Action {
        typealias Output = TimeInterval
    }

}
