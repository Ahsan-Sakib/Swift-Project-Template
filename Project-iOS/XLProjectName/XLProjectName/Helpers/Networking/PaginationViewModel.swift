//
//  DataProvider.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Alamofire
import Foundation
import Argo
import RxSwift

class PaginationViewModel<Element: Decodable where Element.DecodedType == Element> {
    
    let request: PaginationRequest<Element>
    
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    
    let hasNextPage = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let elements = Variable<[Element]>([])
    
    private var disposeBag = DisposeBag()
    
    init(route: RouteType, page: Int) {
        self.request = PaginationRequest(route: route, page: String(1))
        self.bindPaginationRequest(request, nextPage: nil)
    }
    
    private func bindPaginationRequest(paginationRequest: PaginationRequest<Element>, nextPage: String?) {
        disposeBag = DisposeBag()
        
        let refreshRequest = refreshTrigger
            .take(1)
            .map { PaginationRequest<Element>(route: paginationRequest.route, page: String(1)) }
        
        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { () -> Observable<PaginationRequest<Element>> in
                if let page = nextPage {
                    return Observable.of(paginationRequest.routeWithPage(page))
                } else {
                    return Observable.empty()
                }
        }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)
        
        
        let response = request
            .flatMap { $0.rx_paginationCollection() }
            .shareReplay(1)
        
        Observable
            .of(
                request.map { _ in true },
                response.map { _ in false }
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage
                    ? elements + response.elements
                    : response.elements
            }
            .take(1)
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)
        
        response
            .subscribeNext { [weak self] paginationResponse in
                self?.bindPaginationRequest(paginationRequest, nextPage: paginationResponse.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}
