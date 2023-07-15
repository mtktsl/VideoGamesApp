//
//  RAWG_Rating.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_Rating: Decodable {
    public let id: Int?
    public let title: String?
    public let count: Int?
    public let percent: Double?
}
