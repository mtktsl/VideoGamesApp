//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

//The reason we use this as a caseIterable enum is, to make programmers able to use it to generate filter lists
public enum RAWG_GamesListOrderingParameter: String, CaseIterable {
    
    case suggested = ""
    
    case name
    case nameReversed = "-name"
    
    case released
    case releasedReversed = "-released"
    
    case added
    case addedReversed = "-added"
    
    case created
    case createdReversed = "-created"
    
    case updated
    case updatedReversed = "-updated"
    
    case rating
    case ratingReversed = "-rating"
    
    case metacritic
    case metacriticReversed = "-metacritic"
}
