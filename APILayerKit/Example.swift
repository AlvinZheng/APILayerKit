//
//  Example.swift
//  APILayerKit
//
//  Created by 郑青洲 on 2017/10/14.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


/*
 define the api endpoint
 */
enum UserApi {
    case login(name: String, pwd: String)
    case logout
    case userInfo(uid: String)
}

extension UserApi: CloudFunction {
    var path: String {
        return "http:121.201.63.92:8080/myapp/app/"//your server adress
    }
    var functionName: String {
        switch self {
        case .login(name: _, pwd: _):
            return "login"
        case .logout:
            return "logout"
        case .userInfo(uid: _):
            return "queryUserInfo"
        }
    }
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .post
        }
    }
    var headers: [String: String?]? {
        return nil
    }
    var parameters: [String: Any]? {
        switch self {
        case .login(name: let name, pwd: let password):
            return ["account": name, "password":password]
        case .logout:
            return nil
        case .userInfo(uid: let uid):
            return ["userId": uid]
        }
    }
}

/*
 define the model
 the model can parse self from response
 */

struct User {
    let name: String
    
    init(json: JSON) {
        name = json["name"].stringValue
    }
}

extension User: ModelMapAbleFromAF {
    static func makeFromResponse(response: JSON) throws -> [User]? {
        if let arr = response.array {
            var results: [User]? = []
            for obj in arr {
                results!.append(User.init(json: obj))
            }
            return results
        } else {
            let obj = User(json: response)
            return [obj]
        }
    }
}


/*
 call api
 */

class ExampleCaller {
    func exampleCall() {
        let access = ApiAccess()
        let handler = ResponseHandler<User>(onSuccess: { (users) in
            //got the user object
        }) { (err) in
            // handle err
        }
        access.callApi(api: UserApi.userInfo(uid:"testid"), handler: handler)
    }
}
