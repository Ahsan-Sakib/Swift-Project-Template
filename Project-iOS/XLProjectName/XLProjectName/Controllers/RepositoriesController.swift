//
//  RepositoriesController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

class RepositoriesController: XLTableViewController {
    
    var user: User!
    
    lazy var viewModel: PaginationViewModel<Repository>  = { [unowned self] in
        return PaginationViewModel(route: Route.User.Repositories(username: self.user.username))
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading.asDriver(onErrorJustReturn: false)
            .drive(activityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)
        
        viewModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
        
        searchBar.rx_text
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx_valueChanged
            .filter { refreshControl.refreshing }
            .map { false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        tableView.addSubview(refreshControl)
        viewModel.firstPageLoading.filter { $0 == false && refreshControl.refreshing }
            .subscribeNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
    }
}
