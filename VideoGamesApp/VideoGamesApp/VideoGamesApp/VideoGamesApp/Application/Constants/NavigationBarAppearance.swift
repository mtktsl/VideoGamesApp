//
//  NavigationBarAppearance.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import UIKit

extension UINavigationBarAppearance {
    static func standardTransparent() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        return appearance
    }
}
