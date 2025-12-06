//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

public enum NetworkError: Error {
    case decode
    case generic
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
    case parametersNil
    case encodingFailed

    public var customMessage: String {
        switch self {
        case .decode:
            return "Decode Error"
        case .generic:
            return "Generic Error"
        case .invalidURL:
            return "Invalid URL Error"
        case .noResponse:
            return "No Response"
        case .unauthorized:
            return "Unauthorized URL"
        case .unexpectedStatusCode:
            return "Status Code Error"
        case .parametersNil:
            return "Parameters were nil."
        case .encodingFailed:
            return "Parameter encoding failed."
        default:
            return "Unknown Error"
        }
    }
}
