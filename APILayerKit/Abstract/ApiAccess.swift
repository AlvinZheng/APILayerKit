//
//  ApiAccess.swift
//  yijia
//
//  Created by alvin zheng on 17/3/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


typealias NetWorkAccessAble = CloudFunction

typealias ApiAccessAble = CloudFunction


/*
 the response formate should negotiate with server side.
 */

//enum ApiResonseError: Int {
//    case Success = 1
//    case Fail
//}

//customize
//struct ApiResponse {
//    let errorCode: ApiResonseError
//    let data: JSON
//    
//    init(json: JSON) {
//        errorCode = ApiResonseError.init(rawValue: json["errorcode"].intValue) ?? .Fail
//        data = json["data"]
//    }
//}

//enum CloudResponse<T> {
//    case Success(T)
//    case Failure(ApiResonseError)
//}


/*
 define the api error
 */
enum ApiError: Error {
    case mapError
}


class ApiAccess {
    
    var sessionManager: SessionManager?
    /*
     in this method, some settings should negotiate with server side.
     */
    private func genarateRequest(api: NetWorkAccessAble) -> URLRequest {
        let urlstring = api.path.appending(api.functionName)
        let url = URL(string: urlstring)!
        var mutableRequest = URLRequest(url: url)
        mutableRequest.httpMethod = api.method.rawValue
        if let customHeader = api.headers {
            for (key, value) in customHeader {
                mutableRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        mutableRequest.timeoutInterval = 10.0
        mutableRequest.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = api.parameters ?? [:]
        if let token = sessionManager?.accessToken {
            mutableRequest.setValue(token, forHTTPHeaderField: "JSESSIONID")
        }
        return try! Alamofire.URLEncoding().encode(mutableRequest, with: params)
    }
    
    // M : Modle type to parse,should assign a model to parse the respone to get results.
    //
    @discardableResult
    func callApi<M: ModelMapAbleFromAF>(api: ApiAccessAble, handler: ResponseHandler<M>)
        -> ResponseHandler<M> {
//        let innerHanlder: ResponseHandler<M>
//        if let h = handler {
//            innerHanlder = h
//        } else {
//            innerHanlder = ResponseHandler<M>.init(onSuccess: { _ in
//
//            }, onError: { _ in
//
//            })
//        }
        let req = genarateRequest(api: api)
        Alamofire.SessionManager.default.request(req).responseSwiftyJSON() {(response) in
            print(response)
            switch response.result {
            case .success( let res):
                let data = res["obj"]// based on serverside
                if let models = handler.map(response: data) {
                    handler.onSuccess(response: models)
                } else {
                    handler.onError(ApiError.mapError)
                }
            case .failure(let err):
                handler.onError(err)

            }
        }
        return handler
    }
    
}


// generic constraint wrap, gerneric protocol can only used for constraint.
// because swift not surpport this
// and for convenience， we put modle in array ,event it's only one.

class ResponseHandler<M: ModelMapAbleFromAF> {
    func map(response: JSON) -> [M]? {
        do {
            let modles = try M.makeFromResponse(response: response)
            return modles
        }
        catch {
            self.onError(error)
            return nil
        }
    }
    func onSuccess(response: [M]) {
        onSuccess(response)
    }
    fileprivate var onSuccess: ([M]) -> Void
    fileprivate var onError: (_ err: Error) -> Void //print(err.localizeDescreption)}
    
    init(onSuccess: @escaping ([M]) -> Void, onError: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    convenience init() {
        self.init(onSuccess: { (_) in
            
        }) { (_) in
            
        }
    }
    
    @discardableResult
    func onSuccess(block: @escaping ([M]) -> Void) -> Self {
        self.onSuccess = block
        return self
    }
    
    @discardableResult
    func onError(block: @escaping (Error) -> Void) -> Self {
        self.onError = block
        return self
    }
}

