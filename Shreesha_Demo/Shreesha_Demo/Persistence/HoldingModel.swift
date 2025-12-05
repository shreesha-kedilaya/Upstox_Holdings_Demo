//
//  HoldingModel.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//
import Foundation


struct HoldingsResponse: Codable, Sendable {
    let data: HoldingsData
}

struct HoldingsData: Codable, Sendable {
    let userHolding: [Holding]
}
//

struct Holding: Codable, Sendable {
    
    let symbol: String
    let quantity: Int?
    let ltp: Double?
    let avgPrice: Double?
    let close: Double?
    
    // Current Value = quantity * ltp
    var currentValue: Double {
        Double(quantity ?? 0) * (ltp ?? 0)
    }
    
    /// Investment = quantity * average price
    var investmentValue: Double {
        Double(quantity ?? 0) * (avgPrice ?? 0)
    }
    
    /// Total P&L = currentValue - investmentValue
    var totalPnL: Double {
        currentValue - investmentValue
    }
    
    /// Today’s P&L = (close - ltp) * quantity
    var todaysPnL: Double {
        guard let ltp, let close else { return 0 }
        return (close - ltp) * Double(quantity ?? 0)
    }
    
    init?(
        symbol: String?,
        quantity: Int?,
        ltp: Double?,
        avgPrice: Double?,
        close: Double?
    ) {
        // If BE does not send symbol → treat as invalid → return nil
        if let symbol, symbol.isEmpty == false {
            self.symbol = symbol
        } else {
            return nil      // fail the initializer
        }
        
        self.quantity = quantity
        self.ltp = ltp
        self.avgPrice = avgPrice
        self.close = close
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        let symbol = try c.decodeIfPresent(String.self, forKey: .symbol)
        let quantity = try c.decodeIfPresent(Int.self, forKey: .quantity)
        let ltp = try c.decodeIfPresent(Double.self, forKey: .ltp)
        let avgPrice = try c.decodeIfPresent(Double.self, forKey: .avgPrice)
        let close = try c.decodeIfPresent(Double.self, forKey: .close)
        
        // Use the failable initializer
        guard let holding = Holding(
            symbol: symbol,
            quantity: quantity,
            ltp: ltp,
            avgPrice: avgPrice,
            close: close
        ) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: c.codingPath,
                      debugDescription: "Missing or empty symbol")
            )
        }
        
        self = holding
    }
    
}

extension Holding {
    init?(from dbModel: HoldingDBModel) {
        // Validate symbol (required)
        guard
            let symbol = dbModel.symbol,
            symbol.isEmpty == false
        else {
            return nil
        }
        
        self.init(
            symbol: symbol,
            quantity: dbModel.quantity,
            ltp: dbModel.ltp,
            avgPrice: dbModel.avgPrice,
            close: dbModel.close
        )
    }
}
