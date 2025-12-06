//
//  HoldingsViewController.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import Combine
import UIKit
import LayoutKit

final class HoldingsViewController: BaseViewController, HoldingServiceUIInput {
    
    private let viewLoadedLink: PassthroughSubject<Void, Never> = .init()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AnyTableViewCell<HoldingRowView>.self, forCellReuseIdentifier: String(describing: AnyTableViewCell<HoldingRowView>.self))
        tableView.backgroundColor = UIColor(hex: "3A47D9")
        return tableView
    }()
    
    let summaryView = HoldingSummaryView()
    let pnlView = PNLHeaderView()
    
    private lazy var dataSource = HoldingsDataSource(tableView: tableView, viewController: self)
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let loaderView = LoaderView()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel: HoldingServiceUIOutput
    
    init(viewModel: HoldingServiceUIOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewLoadedLink.send(())
        self.title = "Holdings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private var isSummaryHidden = true
    
    @objc func didTapPNL() {
        isSummaryHidden.toggle()
        
        if isSummaryHidden {
            hideSummaryView()
        } else {
            showSummaryView()
        }
    }
}

extension HoldingsViewController {
    func setup() {
        dataSource.setup()
        viewModel.setup()
        bind()
        layout()
        view.backgroundColor = UIColor(hex: "3A47D9")
    }
    
    func bind() {
        viewModel.currentDisplayItems
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    errorLabel.isHidden = false
                    errorLabel.text = failure.localizedDescription
                }
            },receiveValue: { [unowned self] value in
                dataSource.reload()
                errorLabel.isHidden = true
            }).store(in: &subscriptions)
        
        viewModel.showLoader
            .sink(receiveValue: { [unowned self] value in
                if value {
                    showLoader()
                } else {
                    hideLoader()
                }
            }).store(in: &subscriptions)
        viewModel.showError
            .sink(receiveValue: { [unowned self] (show, message) in
                errorLabel.isHidden = !show
                errorLabel.text = message
            }).store(in: &subscriptions)
        
        viewModel.summaryDisplayItem
            .sink { [unowned self] summary in
                if let summary {
                    summaryView.isHidden = false
                    summaryView.configure(with: summary)
                    pnlView.configure(with: .init(amountText: summary.totalPnLText, percentageText: summary.percentageText, isProfit: summary.totalPnLColorIsPositive))
                    pnlView.isHidden = false
                } else {
                    summaryView.isHidden = true
                    pnlView.isHidden = true
                }
            }
            .store(in: &subscriptions)
        
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(summaryView)
        view.addSubview(pnlView)
        view.addSubview(loaderView)
        view.addSubview(errorLabel)
        
        let tapGesture = UITapGestureRecognizer()
                
        pnlView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapPNL))
        
        // Summary view at top
        summaryView.makeConstraint { make in
            make.leading(view)
            make.trailing(view)
            make.above(pnlView)
        }
    
        pnlView.makeConstraint { make in
            make.bottom(view)
            make.sameLeadingTrailing(view)
            make.height(45 + UIApplication.keyWindowSafeAreaInsets().bottom)
        }
        
        pnlView.backgroundColor = UIColor(hex: "3A47D9")
        
        errorLabel.makeConstraint { make in
            make.centerView(view)
        }
        
        loaderView.isUserInteractionEnabled = false
        loaderView.makeConstraint { make in
            make.centerView(view)
            make.size(CGSize(width: 80, height: 80))
        }
        
        tableView.makeConstraint {
            $0.sameLeadingTrailing(view)
            $0.top(view)
            $0.above(pnlView)
        }
        
        let bottom = summaryView.get(.bottom)
        
        Task {
            bottom?.constant = summaryView.bounds.height * 1.2
            view.layoutIfNeeded()
        }
        
        pnlView.changeArrowup()
    }
    
    func showLoader() {
        loaderView.isHidden = false
        loaderView.startAnimating()
    }
    
    func hideLoader() {
        loaderView.stopAnimating()
        loaderView.isHidden = true
    }
    
    func getItems() -> [HoldingRowView.HoldingRowViewModel] {
        return viewModel.currentDisplayItems.value
    }
    
    func hideSummaryView() {
        let bottom = summaryView.get(.bottom)
        bottom?.constant = summaryView.bounds.height * 1.2
        animateLayout()
        
        pnlView.changeArrowup()
    }
    
    func animateLayout() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
        ) {
            self.view.layoutIfNeeded()
        }
    }


    func showSummaryView() {
        let bottom = summaryView.get(.bottom)
        bottom?.constant = 0
        
        animateLayout()
        
        pnlView.changeArrowDown()
    }

}

extension HoldingsViewController {
    var viewLoad: AnyPublisher<Void, Never> {
        return viewLoadedLink.eraseToAnyPublisher()
    }
}
