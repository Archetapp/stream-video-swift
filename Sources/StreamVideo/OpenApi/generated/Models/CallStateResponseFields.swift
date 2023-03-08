//
// CallStateResponseFields.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal struct CallStateResponseFields: Codable, JSONEncodable, Hashable {

    internal var blockedUsers: [UserResponse]
    internal var call: CallResponse
    /** List of call members */
    internal var members: [MemberResponse]
    internal var membership: MemberResponse?

    internal init(blockedUsers: [UserResponse], call: CallResponse, members: [MemberResponse], membership: MemberResponse? = nil) {
        self.blockedUsers = blockedUsers
        self.call = call
        self.members = members
        self.membership = membership
    }

    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case blockedUsers = "blocked_users"
        case call
        case members
        case membership
    }

    // Encodable protocol methods

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blockedUsers, forKey: .blockedUsers)
        try container.encode(call, forKey: .call)
        try container.encode(members, forKey: .members)
        try container.encodeIfPresent(membership, forKey: .membership)
    }
}
