//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation

extension InjectedValues {
    /// Provides access to the `StreamVideo` instance in the views and view models.
    public var streamVideo: StreamVideoClass {
        get {
            guard let injected = Self[StreamVideoClassProviderKey.self] else {
                fatalError("Video client was not setup")
            }
            return injected
        }
        set {
            Self[StreamVideoClassProviderKey.self] = newValue
        }
    }
}
