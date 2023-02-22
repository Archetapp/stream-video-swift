//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal struct CallBlockedUser: Codable, JSONEncodable, Hashable {

    internal var callCid: String
    internal var createdAt: Date
    internal var type: String
    internal var userId: String

    internal init(callCid: String, createdAt: Date, type: String, userId: String) {
        self.callCid = callCid
        self.createdAt = createdAt
        self.type = type
        self.userId = userId
    }

    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case callCid = "call_cid"
        case createdAt = "created_at"
        case type
        case userId = "user_id"
    }

    // Encodable protocol methods

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(callCid, forKey: .callCid)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(type, forKey: .type)
        try container.encode(userId, forKey: .userId)
    }
}
