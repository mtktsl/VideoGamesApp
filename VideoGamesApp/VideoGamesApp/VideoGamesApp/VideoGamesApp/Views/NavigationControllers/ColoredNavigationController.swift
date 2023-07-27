//
//  ColoredNavigationController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import UIKit

class ColoredNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ApplicationConstants.appStatusBarStyle
    }
    
    init() {
        super.init(rootViewController: UIViewController())
        setupAppearance()
    }
    
    private func setupAppearance() {
        navigationBar.standardAppearance = ApplicationConstants.standardTransparent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
