//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 6.03.2023.
//

import Foundation

final class RMCharacterDetailViewViewModel {
    
    private let character: RMCharacter
    
    init(character: RMCharacter){
        self.character = character
    }
    
    public var title: String {
        return character.name.uppercased()
    }
    
}
