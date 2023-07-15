//
//  UIColor+Extension.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

extension UIColor {
    static let maxHueValue: CGFloat = 360
    
    static let appBackgroundColor = UIColor(
        hue: 215 / maxHueValue,
        saturation: 0.44,
        brightness: 0.21,
        alpha: 1
    )
    
    static let appTabBarColor = UIColor(
        hue: 230 / maxHueValue,
        saturation: 0.16,
        brightness: 0.15,
        alpha: 1
    )
    
    static let appGamesListCellBackgroundColor = UIColor(
        hue: 223 / maxHueValue,
        saturation: 0.35,
        brightness: 0.28,
        alpha: 1
    )
    
    static let barTitleColor =  UIColor(
        hue: 204 / maxHueValue,
        saturation: 0.02,
        brightness: 0.90,
        alpha: 1
    )
    
    static let searchTintColor = UIColor(
        hue: 220 / maxHueValue,
        saturation: 0.08,
        brightness: 0.61,
        alpha: 1
    )
    
    
    static let searchBackgroundColor = UIColor(
        hue: 225 / maxHueValue,
        saturation: 0.16,
        brightness: 0.20,
        alpha: 1
    )
}
