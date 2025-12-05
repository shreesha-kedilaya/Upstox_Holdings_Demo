//
//  MainNavigation.swift
//  CryptoCoins
//
//  Created by Shreesha Kedlaya on 10/08/24.
//

import Foundation
import UIKit
import Networking

@MainActor
final class CentralNavigationHandler {
    
    private var rootNavigationController: UINavigationController?
    
    private var currentWindow: UIWindow? {
        didSet {
            currentWindow?.makeKeyAndVisible()
        }
    }
    
    func setupInitialFlow(window: UIWindow) {
        
        let dbService = DatabaseService.shared
        guard let container = dbService.container else {
            return
        }
        let holdingDBService = HoldingsDBService(modelContainer: container)
        let networkService = HoldingService(networkService: NetworkService(), dbService: holdingDBService)
        let viewModel = HoldingViewModel(holdingService: networkService)
        let viewController = HoldingsViewController(viewModel: viewModel)
        viewModel.input = viewController
        let rootNav = UINavigationController(rootViewController: viewController)
        window.rootViewController = rootNav
        self.currentWindow = window
    }
}
