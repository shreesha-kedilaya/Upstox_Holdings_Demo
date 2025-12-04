//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

public typealias RequestHeaders = [String:String]

public enum EncodingTask: Sendable {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: NetworkEncoder,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: NetworkEncoder,
        urlParameters: Parameters?,
        additionHeaders: RequestHeaders?)
    
    // case download, upload...etc
}
