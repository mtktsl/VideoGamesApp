//
//  MainViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

fileprivate extension UIColor {
    static let tabBarColor = UIColor(
        hue: 0,
        saturation: 0,
        brightness: 0.95,
        alpha: 1
    )
}

protocol MainViewControllerProtocol: AnyObject {
    func setupTabBar()
}

final class MainViewController: UITabBarController {
    var viewModel: MainViewModelProtocol!
}

extension MainViewController: MainViewControllerProtocol {
    func setupTabBar() {
        guard let items = self.tabBar.items else { return }
        let imageNames = viewModel.tabbarImages
        for i in 0 ..< items.count {
            items[i].image = UIImage(systemName: imageNames[i])
        }
        tabBar.backgroundColor = .appTabBarColor
        tabBar.unselectedItemTintColor = .barTitleColor
    }
}
