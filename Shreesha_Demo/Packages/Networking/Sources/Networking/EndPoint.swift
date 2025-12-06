//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

public protocol EndPoint: Sendable {
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var requestMethod: RequestMethod { get }
    var task: EncodingTask { get }
    var headers: RequestHeaders? { get }
}

public extension EndPoint {
    var scheme: String {
        return "https"
    }
    var host: String {
        return ""
    }
}
