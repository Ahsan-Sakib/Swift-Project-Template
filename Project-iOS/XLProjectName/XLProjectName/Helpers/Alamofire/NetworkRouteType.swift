//
//  NetworkRouteType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import Argo

protocol NetworkRouteType: URLRequestConvertible {
    var method: Alamofire.Method { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var encoding: Alamofire.ParameterEncoding { get }
}

protocol CustomUrlRequestSetup {
    func customUrlRequestSetup(urlRequest: NSMutableURLRequest)
}

extension NetworkRouteType {
    
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: Constants.Network.baseUrl.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        //        mutableURLRequest.setValue(value: AnyObject?, forKey: String)
        
        
        //        public static func addAuthHeader(request: NSMutableURLRequest, username: String, password: String) {
        //            let utf8 = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        //            let base64 = utf8?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //            guard let encodedString = base64 else { return }
        //            request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
        //        }
        let urlRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        (self as? CustomUrlRequestSetup)?.customUrlRequestSetup(urlRequest)
        return urlRequest
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch method {
        case .POST, .PUT, .PATCH:
            return .JSON
        default:
            return .URL
        }
    }
    
    var parameters: [String: AnyObject]? {
        return nil
    }
    
    func observe<T: Decodable where T == T.DecodedType>(scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Observable<T> {
        return NetworkManager.request(self)
            .validate()
            .rx_object()
            .observeOn(scheduler)
            .doOnError(NetworkManager.generalErrorHandler)
    }
    
    func observe<T: Decodable where T == T.DecodedType>(scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Observable<[T]> {
        return NetworkManager.request(self)
            .validate()
            .rx_objectCollection()
            .observeOn(scheduler)
            .doOnError(NetworkManager.generalErrorHandler)
    }
    
    func observe(scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Observable<AnyObject> {
        return NetworkManager.request(self)
            .validate()
            .rx_JSON()
            .observeOn(scheduler)
            .doOnError(NetworkManager.generalErrorHandler)
    }

}
