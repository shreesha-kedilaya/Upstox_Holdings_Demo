//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

public enum RequestMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
