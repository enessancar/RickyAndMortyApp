//
//  RMRequest.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 2.03.2023.
//

import Foundation

final class RMRequest {
    
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com"
    }
    
    private let endpoint: RMEndpoint
    private let pathComponents: [String]
    private let queryParametres: [URLQueryItem]
    
    public let httpMethod = "GET"
    
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            string += "/"
            pathComponents.forEach({
                string += "\($0)"
            })
        }
        
        if !queryParametres.isEmpty {
            string += "?"
            let argumentString = queryParametres.compactMap({
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            
            string += argumentString
        }
        return string
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
    
    public init(
        endpoint: RMEndpoint,
        pathComponents: [String] = [],
        queryParametres: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParametres = queryParametres
    }
    
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl+"/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endpointString = components[0]
                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint)
                    return
                }
            }
            
        } else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count > 2 {
                let endPointString = components[0]
                let queryItemsString = components[1]
                // value=name&value=name
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")
                    return URLQueryItem(name: parts[0],
                                        value: parts[1])
                })
                if let rmEndpoint = RMEndpoint(rawValue: endPointString) {
                    self.init(endpoint: rmEndpoint, queryParametres: queryItems)
                    return
                }
            }
        }
        return nil
    }
}

extension RMRequest {
    static let listCharactersRequest = RMRequest(endpoint: .character)
}
