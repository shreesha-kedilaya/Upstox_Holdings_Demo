//
//  HoldingSerice.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//


import Foundation
import Networking

struct HoldingEndpoint: EndPoint {
    var headers: RequestHeaders? = nil
    // From: https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/
    var host: String = "35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io"
    var path: String = "/"
    var task: EncodingTask
    var requestMethod: RequestMethod = .get
}

actor HoldingService: HoldingServicable {
    
    private var holdings: [Holding] = []
    
    private var networkService: Networkable
    
    init(networkService: Networkable) {
        self.networkService = networkService
    }
    
    // MARK: - Network
    
    func getHoldings() async -> [Holding] {
        return holdings
    }
    
    func fetchItems() async throws -> [Holding] {
        do {
            
            let response: HoldingsResponse = try await networkService.sendRequest(endpoint: HoldingEndpoint(task: .request))
            self.holdings = response.data.userHolding
                        
            return holdings
        } catch {
            throw error
        }
    }
}

