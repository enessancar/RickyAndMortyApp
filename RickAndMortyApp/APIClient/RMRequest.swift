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
    private let pathComponents: Set<String>
    private let queryParametres: [URLQueryItem]
    
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
    
    public let httpMethod = "GET"
    
    public init(
        endpoint: RMEndpoint,
        pathComponents: Set<String> = [],
        queryParametres: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParametres = queryParametres
    }
}
