//
// StartBroadcastingResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct StartBroadcastingResponse: Codable, JSONEncodable, Hashable {
    /** Duration of the request in human-readable format */
    public var duration: String
    public var playlistUrl: String

    public init(duration: String, playlistUrl: String) {
        self.duration = duration
        self.playlistUrl = playlistUrl
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case duration
        case playlistUrl = "playlist_url"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(duration, forKey: .duration)
        try container.encode(playlistUrl, forKey: .playlistUrl)
    }
}

