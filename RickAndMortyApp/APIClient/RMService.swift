//
//  RMService.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 2.03.2023.
//

import Foundation

final class RMService {
    static let shared = RMService()
    
    private init () {}
    
    public func getRequest(_ request: RMRequest, completion: @escaping() -> Void) {
        
    }
}
