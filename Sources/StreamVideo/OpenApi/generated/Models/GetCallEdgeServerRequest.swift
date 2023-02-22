//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal struct GetCallEdgeServerRequest: Codable, JSONEncodable, Hashable {

    internal var latencyMeasurements: [String: [Float]]

    internal init(latencyMeasurements: [String: [Float]]) {
        self.latencyMeasurements = latencyMeasurements
    }

    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case latencyMeasurements = "latency_measurements"
    }

    // Encodable protocol methods

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latencyMeasurements, forKey: .latencyMeasurements)
    }
}
