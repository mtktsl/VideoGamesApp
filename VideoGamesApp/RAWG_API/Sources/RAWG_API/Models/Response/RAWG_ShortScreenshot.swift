//
//  RAWG_ShortScreenshot.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_ShortScreenshot: Decodable {
    public let id: Int?
    public let imageURLString: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURLString = "image"
    }
}
