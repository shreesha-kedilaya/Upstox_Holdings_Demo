//
//  HoldingDBServicing.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 07/12/25.
//

import Foundation

protocol HoldingsDBServicing: AnyObject, Sendable {
    func deleteHoldings() async throws
    func replaceHoldings(with models: [HoldingDBModel]) async throws
    func appendHoldings(_ models: [HoldingDBModel]) async throws
    func fetchAllHoldings() async throws -> [HoldingDBModel]
}
