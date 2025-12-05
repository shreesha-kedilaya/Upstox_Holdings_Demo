//
//  Untitled.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 05/12/25.
//

import SwiftData

protocol HoldingsDBServicing: AnyObject, Sendable {
    func deleteHoldings() async throws
    func replaceHoldings(with models: [HoldingDBModel]) async throws
    func appendHoldings(_ models: [HoldingDBModel]) async throws
    func fetchAllHoldings() async throws -> [HoldingDBModel]
}

@ModelActor
actor HoldingsDBService: HoldingsDBServicing {

    func deleteHoldings() throws {
        try modelContext.delete(model: HoldingDBModel.self)
    }
    
    func replaceHoldings(with models: [HoldingDBModel]) throws {
        // Delete old holdings
        let descriptor = FetchDescriptor<HoldingDBModel>()
        let existing = try modelContext.fetch(descriptor)
        existing.forEach { modelContext.delete($0) }

        // Insert new ones
        models.forEach { modelContext.insert($0) }

        try modelContext.save()
    }

    func appendHoldings(_ models: [HoldingDBModel]) throws {
        models.forEach { modelContext.insert($0) }
        try modelContext.save()
    }
    
    func fetchAllHoldings() throws -> [HoldingDBModel] {
        let fetchDescriptor = FetchDescriptor<HoldingDBModel>()
        return try modelContext.fetch(fetchDescriptor)
    }
}

