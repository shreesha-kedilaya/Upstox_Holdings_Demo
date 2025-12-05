//
//  HoldingViewModelTests.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 05/12/25.
//

import XCTest
import Combine
@testable import Shreesha_Demo

// MARK: - Protocols from production

protocol HoldingServiceUIInput: AnyObject {
    var viewLoad: AnyPublisher<Void, Never> { get }
}

protocol HoldingServiceUIOutput: AnyObject {}

protocol HoldingServicable {
    func fetchFromLocalStorage() async throws -> [Holding]
    func fetchItems() async throws -> [Holding]
    func getHoldings() async -> [Holding]
}

// Minimal model to satisfy tests
struct Holding: Hashable {
    let symbol: String
    let quantity: Double
    let ltp: Double
    let avgPrice: Double
    let close: Double

    var currentValue: Double { quantity * ltp }
    var investmentValue: Double { quantity * avgPrice }
    var todaysPnL: Double { (ltp - close) * quantity }

    func getViewModel() -> HoldingRowView.HoldingRowViewModel {
        let pnl = (ltp - avgPrice) * quantity
        return .init(
            symbol: symbol,
            quantityText: "NET QTY: \(Int(quantity))",
            ltpText: "LTP: \(ltp.fmt())",
            pnlText: pnl.fmt(),
            pnlColorIsPositive: pnl >= 0
        )
    }
}

// MARK: - Mocks

final class MockHoldingService: HoldingServicable {
    var fetchFromLocalStorageResult: Result<[Holding], Error> = .success([])
    var fetchItemsResult: Result<[Holding], Error> = .success([])
    var getHoldingsResult: [Holding] = []

    func fetchFromLocalStorage() async throws -> [Holding] {
        try fetchFromLocalStorageResult.get()
    }

    func fetchItems() async throws -> [Holding] {
        try fetchItemsResult.get()
    }

    func getHoldings() async -> [Holding] {
        getHoldingsResult
    }
}

final class MockHoldingServiceUIInput: HoldingServiceUIInput {
    let viewLoadSubject = PassthroughSubject<Void, Never>()
    var viewLoad: AnyPublisher<Void, Never> { viewLoadSubject.eraseToAnyPublisher() }

    init(viewModel: HoldingViewModel) {}
}

// MARK: - Tests

@MainActor
final class HoldingViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var viewModel: HoldingViewModel!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        super.tearDown()
    }

    // Helpers
    private func makeViewModel(service: MockHoldingService = MockHoldingService()) -> (HoldingViewModel, MockHoldingService, MockHoldingServiceUIInput) {
        let vm = HoldingViewModel(holdingService: service)
        let input = MockHoldingServiceUIInput(viewModel: vm)
        vm.input = input as? HoldingServiceUIInput
        vm.setup()
        return (vm, service, input)
    }

    func testServerSuccess_updatesItemsAndSummary() {
        let mock = MockHoldingService()
        mock.fetchFromLocalStorageResult = .success([]) // force server path
        let holdings = [
            Holding(symbol: "AAA", quantity: 1, ltp: 10, avgPrice: 8, close: 9),
            Holding(symbol: "BBB", quantity: 2, ltp: 5, avgPrice: 7, close: 5)
        ]
        mock.fetchItemsResult = .success(holdings)

        let (vm, _, input) = makeViewModel(service: mock)
        self.viewModel = vm

        let itemsExpectation = expectation(description: "items emitted from server")
        let summaryExpectation = expectation(description: "summary emitted from server")

        vm.currentDisplayItems
            .dropFirst()
            .sink(receiveCompletion: { _ in }, receiveValue: { items in
                XCTAssertEqual(items.count, 2)
                itemsExpectation.fulfill()
            })
            .store(in: &cancellables)

        vm.summaryDisplayItem
            .dropFirst()
            .sink { summary in
                XCTAssertNotNil(summary)
                summaryExpectation.fulfill()
            }
            .store(in: &cancellables)

        input.viewLoadSubject.send(())

        wait(for: [itemsExpectation, summaryExpectation], timeout: 1.0)
    }

    func testServerReturnsEmpty_keepsEmptyStateAndShowsError() {
        let mock = MockHoldingService()
        mock.fetchFromLocalStorageResult = .success([])
        mock.fetchItemsResult = .success([])
        mock.getHoldingsResult = []

        let (vm, _, input) = makeViewModel(service: mock)
        self.viewModel = vm

        let errorExpectation = expectation(description: "error shown on empty server response")

        vm.showError
            .sink { show, _ in
                if show { errorExpectation.fulfill() }
            }
            .store(in: &cancellables)

        input.viewLoadSubject.send(())

        wait(for: [errorExpectation], timeout: 1.0)
        XCTAssertTrue(vm.currentDisplayItems.value.isEmpty)
        XCTAssertNil(vm.summaryDisplayItem.value)
    }

    func testServerError_completesWithFailureAndShowsError() {
        enum MockApiError: Error { case failed }
        let mock = MockHoldingService()
        mock.fetchFromLocalStorageResult = .success([])
        mock.fetchItemsResult = .failure(MockApiError.failed)

        let (vm, _, input) = makeViewModel(service: mock)
        self.viewModel = vm

        let completionExpectation = expectation(description: "items completed with error")
        let errorExpectation = expectation(description: "error shown on server failure")

        vm.currentDisplayItems
            .sink { completion in
                if case .failure = completion { completionExpectation.fulfill() }
            } receiveValue: { _ in }
            .store(in: &cancellables)

        vm.showError
            .sink { show, _ in
                if show { errorExpectation.fulfill() }
            }
            .store(in: &cancellables)

        input.viewLoadSubject.send(())

        wait(for: [completionExpectation, errorExpectation], timeout: 1.0)
        XCTAssertTrue(vm.currentDisplayItems.value.isEmpty)
        XCTAssertNil(vm.summaryDisplayItem.value)
    }
}
