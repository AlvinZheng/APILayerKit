//
//  Api.swift
//  yijia
//
//  Created by alvin zheng on 17/3/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation
import Alamofire

/*
 like the Moya, 
 mostly use an enum to conform this protocol, to define the server side service.
 */
protocol CloudFunction {
    var path: String { get }
    var functionName: String { get }
    var method: Alamofire.HTTPMethod { get }
    var headers: [String: String?]? { get }
    var parameters: [String: Any]? { get }
}
