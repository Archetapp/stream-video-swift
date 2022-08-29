//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

// Generated by protoc-gen-siwftwirp. DO NOT EDIT
import Foundation
import SwiftProtobuf

class Stream_Video_Sfu_SignalServer {
    private let httpClient: HTTPClient
    var hostname: String
    var token: String
    var apiKey: String

    let pathPrefix: String = "/stream.video.sfu.SignalServer/"

    init(httpClient: HTTPClient, apiKey: String, hostname: String, token: String) {
        self.httpClient = httpClient
        self.hostname = hostname
        self.token = token
        self.apiKey = apiKey
    }
    
    func join(joinRequest: Stream_Video_Sfu_JoinRequest) async throws -> Stream_Video_Sfu_JoinResponse {
        try await execute(request: joinRequest, path: "Join")
    }
    
    func setPublisher(setPublisherRequest: Stream_Video_Sfu_SetPublisherRequest) async throws
        -> Stream_Video_Sfu_SetPublisherResponse {
        try await execute(request: setPublisherRequest, path: "SetPublisher")
    }
    
    func sendAnswer(sendAnswerRequest: Stream_Video_Sfu_SendAnswerRequest) async throws -> Stream_Video_Sfu_SendAnswerResponse {
        try await execute(request: sendAnswerRequest, path: "SendAnswer")
    }
    
    func sendIceCandidate(iceCandidateRequest: Stream_Video_Sfu_IceCandidateRequest) async throws
        -> Stream_Video_Sfu_IceCandidateResponse {
        try await execute(request: iceCandidateRequest, path: "SendIceCandidate")
    }
    
    func updateSubscriptions(updateSubscriptionsRequest: Stream_Video_Sfu_UpdateSubscriptionsRequest) async throws
        -> Stream_Video_Sfu_UpdateSubscriptionsResponse {
        try await execute(request: updateSubscriptionsRequest, path: "UpdateSubscriptions")
    }
    
    func updateMuteState(updateMuteStateRequest: Stream_Video_Sfu_UpdateMuteStateRequest) async throws
        -> Stream_Video_Sfu_UpdateMuteStateResponse {
        try await execute(request: updateMuteStateRequest, path: "UpdateMuteState")
    }
    
    func requestVideoQuality(updateVideoQualityRequest: Stream_Video_Sfu_UpdateVideoQualityRequest) async throws
        -> Stream_Video_Sfu_UpdateVideoQualityResponse {
        try await execute(request: updateVideoQualityRequest, path: "RequestVideoQuality")
    }
    
    func update(userToken: String) {
        token = userToken
    }
    
    private func execute<Request: ProtoModel, Response: ProtoModel>(request: Request, path: String) async throws -> Response {
        let requestData = try request.serializedData()
        var request = try makeRequest(for: path)
        request.httpBody = requestData
        let responseData = try await httpClient.execute(request: request)
        let response = try Response(serializedData: responseData)
        return response
    }
    
    private func makeRequest(for path: String) throws -> URLRequest {
        let url = hostname + pathPrefix + path + "?api_key=\(apiKey)"
        guard let url = URL(string: url) else {
            throw NSError(domain: "stream", code: 123)
        }
        var request = URLRequest(url: url)
        request.setValue("application/protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.httpMethod = "POST"
        return request
    }
}