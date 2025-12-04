//
//  DataStack.swift
//  CryptoCoins
//
//  Created by Shreesha Kedlaya on 12/08/24.
//

import Foundation
import SwiftData

protocol DatabaseServicable: AnyObject, Sendable {
    var container: ModelContainer? { get }
    var context: ModelContext? { get }
    
}

final class DatabaseService: DatabaseServicable, @unchecked Sendable {
    static let shared = DatabaseService()
    var container: ModelContainer?
    var context: ModelContext?

    init() {
//        do {
//            container = try ModelContainer(for: Holding.self)
//            if let container {
//                context = ModelContext(container)
//                context?.autosaveEnabled = true
//            }
//        } catch {
//            print("Error initializing database container:", error)
//            // Consider throwing an error or providing a fallback mechanism here
//        }
    }
}
