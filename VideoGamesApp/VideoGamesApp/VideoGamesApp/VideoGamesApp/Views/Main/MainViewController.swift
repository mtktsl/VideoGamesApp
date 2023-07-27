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
    func setBadge()
    func cleanBadge()
}

final class MainViewController: UITabBarController {
    var viewModel: MainViewModelProtocol!
    
    private var didSetupTabBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onFavoritesChanged(_:)),
            name: CoreDataManager.NotificationNames.newItem,
            object: nil
        )
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setupTabBar()
        viewModel.fetchCoreData()
    }
    
    @objc private func onFavoritesChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let isEmpty = notification.object as? Bool, !isEmpty {
                setBadge()
            } else {
                cleanBadge()
            }
        }
    }
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
        didSetupTabBar = true
    }
    
    func setBadge() {
        if !didSetupTabBar { return }
        
        let favoriteItem = tabBar.items?[viewModel.badgeTabBarIndex]
        
        favoriteItem?.badgeColor = .systemBlue
        favoriteItem?.badgeValue = "!"
    }
    
    func cleanBadge() {
        tabBar.items?[viewModel.badgeTabBarIndex].badgeValue = nil
    }
}
