//
//  SplashViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit
import NSLayoutConstraintExtensionPackage

fileprivate extension UIEdgeInsets {
    static let imagePadding = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
}

class SplashViewController: UIViewController {
    
    var viewModel: SplashViewModelProtocol!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkInternetConnection()
    }
    
    func setupImageView() {
        imageView.image = UIImage(named: viewModel.imageAssetName)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(
            imageView,
            to: view,
            padding: .imagePadding
        )
    }
}
