//
//  HolidngServicable.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import Combine
import Foundation

protocol HoldingServicable: AnyObject, Sendable {
    func fetchItems() async throws -> [Holding]
    
    func getHoldings() async -> [Holding]
}
