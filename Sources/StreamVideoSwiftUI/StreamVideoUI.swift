//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamVideo

public class StreamVideoUI {
    var streamVideo: StreamVideo
    var appearance: Appearance
    
    public init(
        streamVideo: StreamVideo,
        appearance: Appearance = Appearance()
    ) {
        self.streamVideo = streamVideo
        self.appearance = appearance
        AppearanceKey.currentValue = appearance
    }
    
}

extension InjectedValues {
    
    /// Provides access to the `Colors` instance.
    public var colors: Colors {
        get {
            appearance.colors
        }
        set {
            appearance.colors = newValue
        }
    }
    
    /// Provides access to the `Images` instance.
    public var images: Images {
        get {
            appearance.images
        }
        set {
            appearance.images = newValue
        }
    }
    
    /// Provides access to the `Fonts` instance.
    public var fonts: Fonts {
        get {
            appearance.fonts
        }
        set {
            appearance.fonts = newValue
        }
    }
    
}