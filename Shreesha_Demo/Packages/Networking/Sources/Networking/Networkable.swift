//
//  File.swift
//
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation
import Combine

public protocol Networkable: Sendable {
    func sendRequest<T: Decodable>(urlStr: String) async throws -> T
    func sendRequest<T: Decodable>(endpoint: EndPoint) async throws -> T
    func sendRequest<T: Decodable>(endpoint: EndPoint, type: T.Type) -> AnyPublisher<T, NetworkError>
}

public final class NetworkService: Networkable, @unchecked Sendable {
    
    private var urlSession: URLSession
    private weak var sessionDelegate: URLSessionDelegate?
    private var _timeoutInterval: TimeInterval = 10
    
    public init(session: URLSession = URLSession.shared,
                delegate: URLSessionDelegate? = nil,
                timeoutInterval: TimeInterval = 10) {
        self.urlSession = session
        self.sessionDelegate = delegate
        self._timeoutInterval = timeoutInterval
    }
    
    public func sendRequest<T>(urlStr: String) async throws -> T where T : Decodable {
        guard let urlStr = urlStr as String?, let url = URL(string: urlStr) as URL?else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await urlSession.data(from: url)
        Self.log(response: response as? HTTPURLResponse, data: data, error: nil)
        guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            throw NetworkError.unexpectedStatusCode
        }
        guard let data = data as Data? else {
            throw NetworkError.unknown
        }
        guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkError.decode
        }
        return decodedResponse
    }
    
    public func sendRequest<T: Decodable>(endpoint: EndPoint) async throws -> T {
        let urlRequest = try createRequest(endPoint: endpoint)
        Self.log(request: urlRequest)
        let (data, response) = try await urlSession.data(for: urlRequest)
        Self.log(response: response as? HTTPURLResponse, data: data, error: nil)
        guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            throw NetworkError.unexpectedStatusCode
        }
        guard let data = data as Data? else {
            throw NetworkError.unknown
        }
        guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkError.decode
        }
        return decodedResponse
    }
    
    public func sendRequest<T>(endpoint: any EndPoint, type: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        guard let urlRequest = try? createRequest(endPoint: endpoint) else {
            preconditionFailure("Failed URLRequest")
        }
        return urlSession.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    throw NetworkError.invalidURL
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decode
                } else if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    private static func log(request: URLRequest) {
        
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        print(String.buildString {
            "\(urlAsString) \n"
            "\(method) \(path)?\(query) HTTP/1.1"
            "HOST: \(host)"
            
            for (key,value) in request.allHTTPHeaderFields ?? [:] {
                "\(key): \(value)"
            }
            
            if let body = request.httpBody {
                "\(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
            }
        })
    }
    
    private static func log(response: HTTPURLResponse?, data: Data?, error: Error?) {
        print("\n - - - - - - - - - - INCOMMING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        print(String.buildString {
            if let urlString = urlString {
                "\(urlString)"
                "\n"
            }
            if let statusCode =  response?.statusCode {
                "HTTP \(statusCode) \(path)?\(query)"
            }
            if let host = components?.host {
                "Host: \(host)"
            }
            for (key, value) in response?.allHeaderFields ?? [:] {
                "\(key): \(value)"
            }
            if let body = data {
                "\(String(data: body, encoding: .utf8) ?? "")"
            }
            if error != nil {
                "Error: \(error!.localizedDescription)"
            }
        })
    }
}

extension Networkable {
    fileprivate func createRequest(endPoint: EndPoint) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = endPoint.scheme
        urlComponents.host = endPoint.host
        urlComponents.path = endPoint.path
        
        guard let url = urlComponents.url else {
            throw NetworkError.decode
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = endPoint.requestMethod.rawValue
        do {
            switch endPoint.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: NetworkEncoder,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: RequestHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
