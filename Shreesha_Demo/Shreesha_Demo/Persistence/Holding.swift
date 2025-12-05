//
//  Holdings.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import Foundation
import SwiftData

struct HoldingsResponse: Codable, Sendable {
    let data: HoldingsData
}

struct HoldingsData: Codable, Sendable {
    let userHolding: [Holding]
}
//
////@Model
//struct Holding: Codable, Hashable, Sendable {
//    
//    let symbol: String?
//    let quantity: Int?
//    let ltp: Double?
//    let avgPrice: Double?
//    let close: Double?
    
    // MARK: - Computed Properties
    
//    /// Current Value = quantity * ltp
//    var currentValue: Double {
//        Double(quantity ?? 0) * (ltp ?? 0)
//    }
//    
//    /// Investment = quantity * average price
//    var investmentValue: Double {
//        Double(quantity ?? 0) * (avgPrice ?? 0)
//    }
//    
//    /// Total P&L = currentValue - investmentValue
//    var totalPnL: Double {
//        currentValue - investmentValue
//    }
//    
//    /// Today’s P&L = (close - ltp) * quantity
//    var todaysPnL: Double {
//        guard let ltp, let close else { return 0 }
//        return (close - ltp) * Double(quantity ?? 0)
//    }
    
    // MARK: - Init
    
//    init(symbol: String? = nil,
//         quantity: Int? = nil,
//         ltp: Double? = nil,
//         avgPrice: Double? = nil,
//         close: Double? = nil) {
//        self.symbol = symbol
//        self.quantity = quantity
//        self.ltp = ltp
//        self.avgPrice = avgPrice
//        self.close = close
//    }

    // MARK: - Codable

//    enum CodingKeys: String, CodingKey {
//        case symbol
//        case quantity
//        case ltp
//        case avgPrice = "avg_price"
//        case close
//    }
////    
////    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        symbol = try? container.decodeIfPresent(String.self, forKey: .symbol)
//        quantity = try? container.decodeIfPresent(Int.self, forKey: .quantity)
//        ltp = try? container.decodeIfPresent(Double.self, forKey: .ltp)
//        avgPrice = try? container.decodeIfPresent(Double.self, forKey: .avgPrice)
//        close = try? container.decodeIfPresent(Double.self, forKey: .close)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(symbol, forKey: .symbol)
//        try container.encodeIfPresent(quantity, forKey: .quantity)
//        try container.encodeIfPresent(ltp, forKey: .ltp)
//        try container.encodeIfPresent(avgPrice, forKey: .avgPrice)
//        try container.encodeIfPresent(close, forKey: .close)
//    }
//}
