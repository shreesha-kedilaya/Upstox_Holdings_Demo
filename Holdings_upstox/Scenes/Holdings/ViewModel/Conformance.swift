//
//  Conformance.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//


import Foundation
import Combine
import UIKit


// MARK: - UI Contracts

protocol HoldingServiceUIInput: AnyObject {
    var viewModel: HoldingServiceUIOutput { get }
    var viewLoad: AnyPublisher<Void, Never> { get }
}

protocol HoldingServiceUIOutput: AnyObject {
    var input: HoldingServiceUIInput? { get set }
    
    /// List of holdings to display in the table
    var currentDisplayItems: CurrentValueSubject<[HoldingRowView.HoldingRowViewModel], Error> { get }
    
    /// Summary view model (current value, invested, P&L)
    var summaryDisplayItem: CurrentValueSubject<HoldingSummaryView.SummaryViewModel?, Never> { get }
    
    /// Loader ON/OFF
    var showLoader: PassthroughSubject<Bool, Never> { get }
    
    /// (showError, message)
    var showError: PassthroughSubject<(Bool, String), Never> { get }
    
    func setup()
}
