//
//  ModelMap.swift
//  yijia
//
//  Created by alvin zheng on 17/3/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


/*
 the model conform this to parse data from server side.
 
 */
protocol ModelMapAbleFromAF {
    static func makeFromResponse(response: JSON) throws -> [Self]?
}
