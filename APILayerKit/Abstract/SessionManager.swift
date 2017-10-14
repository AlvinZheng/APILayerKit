//
//  SessionManager.swift
//  yijia
//
//  Created by alvin zheng on 17/3/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation


/*
 sometimes,the request need token, conform this protocol to manager
 session informations.
 */
protocol SessionManager {
    var accessToken: String? { get }
    func updateToken(newToken: String)
    func handleTokenExpire()
}
