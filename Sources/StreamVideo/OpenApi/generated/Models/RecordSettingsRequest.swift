//
// RecordSettingsRequest.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct RecordSettingsRequest: Codable, JSONEncodable, Hashable {
    public enum Mode: String, Codable, CaseIterable {
        case available = "available"
        case disabled = "disabled"
        case autoOn = "auto-on"
    }
    public enum Quality: String, Codable, CaseIterable {
        case audioOnly = "audio-only"
        case _360p = "360p"
        case _480p = "480p"
        case _720p = "720p"
        case _1080p = "1080p"
        case _1440p = "1440p"
    }
    public var audioOnly: Bool?
    public var mode: Mode?
    public var quality: Quality?

    public init(audioOnly: Bool? = nil, mode: Mode? = nil, quality: Quality? = nil) {
        self.audioOnly = audioOnly
        self.mode = mode
        self.quality = quality
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case audioOnly = "audio_only"
        case mode
        case quality
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(audioOnly, forKey: .audioOnly)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(quality, forKey: .quality)
    }
}

