//
//  HoldingServiceMock.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 05/12/25.
//

import Combine
@testable import Shreesha_Demo

final class MockHoldingService: HoldingServicable {

    // MARK: - Configurable results

    var fetchItemsResult: Result<[Holding], Error> = .success([])
    var getHoldingsResult: [Holding] = []
    var fetchFromLocalStorageResult: Result<[Holding], Error> = .success([])

    // MARK: - Call tracking

    private(set) var deleteHoldingsCalled = false
    private(set) var saveAllToLocalCalled = false

    // MARK: - HoldingServicable

    func fetchItems() async throws -> [Holding] {
        try fetchItemsResult.get()
    }

    func getHoldings() async -> [Holding] {
        getHoldingsResult
    }

    func fetchFromLocalStorage() async throws -> [Holding] {
        try fetchFromLocalStorageResult.get()
    }

    func deleteHoldings() async throws {
        deleteHoldingsCalled = true
    }

    func saveAllToLocal() async throws {
        saveAllToLocalCalled = true
    }
}

// Conform to Sendable just for tests
extension MockHoldingService: @unchecked Sendable {}


// MARK: - Tests
