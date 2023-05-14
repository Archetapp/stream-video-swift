//
// APIError.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif





internal struct APIError: Codable, JSONEncodable, Hashable {

    internal enum Code: String, Codable, CaseIterable {
        case internalError = "internal-error"
        case accessKeyError = "access-key-error"
        case inputError = "input-error"
        case authFailed = "auth-failed"
        case duplicateUsername = "duplicate-username"
        case rateLimited = "rate-limited"
        case notFound = "not-found"
        case notAllowed = "not-allowed"
        case eventNotSupported = "event-not-supported"
        case channelFeatureNotSupported = "channel-feature-not-supported"
        case messageTooLong = "message-too-long"
        case multipleNestingLevel = "multiple-nesting-level"
        case payloadTooBig = "payload-too-big"
        case expiredToken = "expired-token"
        case tokenNotValidYet = "token-not-valid-yet"
        case tokenUsedBeforeIat = "token-used-before-iat"
        case invalidTokenSignature = "invalid-token-signature"
        case customCommandEndpointMissing = "custom-command-endpoint-missing"
        case customCommandEndpointEqualCallError = "custom-command-endpoint=call-error"
        case connectionIdNotFound = "connection-id-not-found"
        case coolDown = "cool-down"
        case queryChannelPermissionsMismatch = "query-channel-permissions-mismatch"
        case tooManyConnections = "too-many-connections"
        case notSupportedInPushV1 = "not-supported-in-push-v1"
        case moderationFailed = "moderation-failed"
        case videoProviderNotConfigured = "video-provider-not-configured"
        case videoInvalidCallId = "video-invalid-call-id"
        case videoCreateCallFailed = "video-create-call-failed"
        case appSuspended = "app-suspended"
        case videoNoDatacentersAvailable = "video-no-datacenters-available"
        case videoJoinCallFailure = "video-join-call-failure"
        case queryCallsPermissionsMismatch = "query-calls-permissions-mismatch"
    }
    /** Response HTTP status code */
    internal var statusCode: Int
    /** API error code */
    internal var code: Code
    /** Additional error-specific information */
    internal var details: [Int]
    /** Request duration */
    internal var duration: String
    /** Additional error info */
    internal var exceptionFields: [String: String]?
    /** Message describing an error */
    internal var message: String
    /** URL with additional information */
    internal var moreInfo: String

    internal init(statusCode: Int, code: Code, details: [Int], duration: String, exceptionFields: [String: String]? = nil, message: String, moreInfo: String) {
        self.statusCode = statusCode
        self.code = code
        self.details = details
        self.duration = duration
        self.exceptionFields = exceptionFields
        self.message = message
        self.moreInfo = moreInfo
    }

    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case statusCode = "StatusCode"
        case code
        case details
        case duration
        case exceptionFields = "exception_fields"
        case message
        case moreInfo = "more_info"
    }

    // Encodable protocol methods

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(code, forKey: .code)
        try container.encode(details, forKey: .details)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(exceptionFields, forKey: .exceptionFields)
        try container.encode(message, forKey: .message)
        try container.encode(moreInfo, forKey: .moreInfo)
    }
}

