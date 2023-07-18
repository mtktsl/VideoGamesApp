//
//  CoordinatorProtocol.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get }
    var navigationController: UINavigationController? { get }
    var appDelegate: AppDelegate? { get }
    func popupError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    )
    func start()
}

extension CoordinatorProtocol {
    func popupError(
        title: String,
        message: String,
        okOption: String? = nil,
        cancelOption: String? = nil,
        onOk: ((UIAlertAction) -> Void)? = nil,
        onCancel: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: okOption ?? "OK",
            style: .default,
            handler: onOk
        )
        alertVC.addAction(okAction)
        
        if let cancelOption {
            let exitAction = UIAlertAction(
                title: cancelOption,
                style: .destructive,
                handler: onCancel
            )
            alertVC.addAction(exitAction)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            navigationController?.visibleViewController?.present(alertVC, animated: true)
        }
        
    }
}
