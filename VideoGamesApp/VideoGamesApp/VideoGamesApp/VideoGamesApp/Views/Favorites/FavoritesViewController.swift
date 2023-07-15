//
//  FavoritesViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

protocol FavoritesViewControllerProtocol {
    
}

final class FavoritesViewController: UIViewController {
    
    var viewModel: FavoritesViewModelProtocol! {
        didSet {
            title = viewModel.viewControllerTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackgroundColor
        
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    
}
