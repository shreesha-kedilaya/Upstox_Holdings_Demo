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
        
        let networkService = HoldingService(networkService: NetworkService())
        let viewModel = HoldingViewModel(holdingService: networkService)
        let viewController = HoldingsViewController(viewModel: viewModel)
        viewModel.input = viewController
        let rootNav = UINavigationController(rootViewController: viewController)
        window.rootViewController = rootNav
        self.currentWindow = window
    }
}
