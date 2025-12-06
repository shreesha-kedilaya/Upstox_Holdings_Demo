//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
