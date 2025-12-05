//
//  HoldingsViewModel.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//


import Foundation
import Networking
import Combine

// MARK: - ViewModel

@MainActor
final class HoldingViewModel: HoldingServiceUIOutput {
    
    weak var input: HoldingServiceUIInput?
    
    private var holdingService: HoldingServicable
    
    private lazy var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: - Outputs
    
    var currentDisplayItems: CurrentValueSubject<[HoldingRowView.HoldingRowViewModel], Error> = .init([])
    var summaryDisplayItem: CurrentValueSubject<HoldingSummaryView.SummaryViewModel?, Never> = .init(nil)
    
    var showLoader: PassthroughSubject<Bool, Never> = .init()
    var showError: PassthroughSubject<(Bool, String), Never> = .init()
    
    // MARK: - Init
    
    init(holdingService: HoldingServicable) {
        self.holdingService = holdingService
    }
    
    // MARK: - Setup
    
    func setup() {
        input?.viewLoad
            .sink { [weak self] in
                guard let self else { return }
                self.handleViewLoad()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Private

private extension HoldingViewModel {
    
    func handleViewLoad() {
        showLoader.send(true)
        
        print("View loaded")
        Task { [weak self] in
            guard let self else { return }
            
            // 1. Load cache first
            await self.fetchLocalStorage()
            
            try Task.checkCancellation()
            // 2. Call API
//            await self.callApi()
            print("View recieved result")
            self.showLoader.send(false)
        }.store(in: &subscriptions)
    }
    
    func fetchLocalStorage() async {
        do {
            let localCache = try await holdingService.fetchFromLocalStorage()
            let sorted = Self.getSorted(items: localCache)
            currentDisplayItems.send(sorted.map{ $0.getViewModel() })
            updateSummary(with: sorted)
            showError.send((false, ""))
            print(" testing Completed")
        } catch {
            debugPrint("Holding local fetch error:", error)
        }
    }
    
    func callApi() async {
        do {
            let items = try await holdingService.fetchItems()
            let sorted = Self.getSorted(items: items)
            currentDisplayItems.send(sorted.map { $0.getViewModel() })
            updateSummary(with: sorted)
            showError.send((false, ""))
        } catch {
            let items = await holdingService.getHoldings()
            
            if items.isEmpty {
                currentDisplayItems.send(completion: .failure(error))
                showError.send((true, "Failed to load holdings"))
            } else {
                let sorted = Self.getSorted(items: items)
                currentDisplayItems.send(sorted.map { $0.getViewModel() })
                updateSummary(with: sorted)
                showError.send((false, ""))
            }
        }
    }
    
    static func getSorted(items: [Holding]) -> [Holding] {
        return items.sorted { ($0.symbol) < ($1.symbol) }
    }
    
    func updateSummary(with items: [Holding]) {
        guard !items.isEmpty else {
            summaryDisplayItem.send(nil)
            return
        }
        
        let currentValue = items.reduce(0) { $0 + $1.currentValue }
        let totalInvestment = items.reduce(0) { $0 + $1.investmentValue }
        let totalPnL = currentValue - totalInvestment
        let todaysPnL = items.reduce(0) { $0 + $1.todaysPnL }
        let percentage = (totalPnL / totalInvestment) * 100
                
        let summaryVM = HoldingSummaryView.SummaryViewModel(
            currentValueText: currentValue.fmt(),
            investmentText: totalInvestment.fmt(),
            totalPnLText: totalPnL.fmt(),
            todaysPnLText: todaysPnL.fmt(),
            totalPnLColorIsPositive: totalPnL >= 0,
            todaysPnLColorIsPositive: todaysPnL >= 0,
            percentageText: String(format: " (%.2f%%)", percentage)
        )
        
        summaryDisplayItem.send(summaryVM)
    }
}

extension Formatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹ "
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    func fmt() -> String {
        Formatter.currencyFormatter.string(from: self as NSNumber) ?? "\(self)"
    }
}


public protocol TaskCancellable: Hashable, Sendable {
    func cancel()
}

extension Task: TaskCancellable {}


extension Task {
    public func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(cancel))
    }
}
