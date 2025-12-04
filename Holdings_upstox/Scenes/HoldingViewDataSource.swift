//
//  HoldingViewDataSource.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import Foundation
import UIKit

final class HoldingsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Private
    
    private weak var tableView: UITableView?
    private weak var viewController: HoldingsViewController?
    
    // MARK: - Init
    
    init(tableView: UITableView, viewController: HoldingsViewController) {
        self.tableView = tableView
        self.viewController = viewController
        super.init()
    }
    
    // MARK: - Public
    
    func setup() {
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewController?.getItems().count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let identifier = String(describing: AnyTableViewCell<HoldingRowView>.self)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as? AnyTableViewCell<HoldingRowView>
        
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        
        if let rowVM = viewController?.getItems()[safe: indexPath.item] {
            cell?.wrappedView.configure(with: rowVM)
        }
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70
    }
}

extension Holding {
    func getViewModel() -> HoldingRowView.HoldingRowViewModel {
        let formatter = Formatter.currencyFormatter
        let ltpString = formatter.string(from: (self.ltp ?? 0) as NSNumber) ?? "\(String(describing: self.ltp))"
        let pnl = self.totalPnL
        let pnlString = formatter.string(from: pnl as NSNumber) ?? "\(pnl)"
        return HoldingRowView.HoldingRowViewModel(
            symbol: self.symbol,
            quantityText: "NET QTY: \(self.quantity ?? 0)",
            ltpText: "LTP: \(ltpString)",
            pnlText: pnlString,
            pnlColorIsPositive: pnl >= 0
        )
    }
}
