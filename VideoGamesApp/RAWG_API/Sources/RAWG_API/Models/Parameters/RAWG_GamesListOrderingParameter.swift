//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

//The reason we use this as a caseIterable enum is, to make programmers able to use it to generate filter lists
public enum RAWG_GamesListOrderingParameter: String, CaseIterable {
    case name
    case released
    case added
    case created
    case updated
    case rating
    case metacritic
    
    case nameReversed = "-name"
    case releasedReversed = "-released"
    case addedReversed = "-added"
    case createdReversed = "-created"
    case updatedReversed = "-updated"
    case ratingReversed = "-rating"
    case metacriticReversed = "-metacritic"
}
