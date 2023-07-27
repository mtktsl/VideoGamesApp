//
//  NavigationBarAppearance.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import UIKit

extension ApplicationConstants {
    static func standardTransparent() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        return appearance
    }
    
    //TODO: - make a global variable and return a style according to that color style of the app.
    static var appStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
