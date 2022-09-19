//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

final class LatencyService: Sendable {
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func measureLatency(for edge: Stream_Video_Edge, tries: Int = 1) async -> [Float] {
        guard let url = URL(string: edge.latencyURL) else { return [Float(Int.max)] }
        var results = [Float]()
        for _ in 0..<tries {
            let startDate = Date()
            let request = URLRequest(url: url)
            do {
                _ = try await httpClient.execute(request: request)
                let diff = Float(Date().timeIntervalSince(startDate))
                results.append(diff)
            } catch {
                results.append(Float(Int.max))
            }
        }
        return results
    }
}
