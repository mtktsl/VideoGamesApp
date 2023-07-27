//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation

internal enum ModalPickerRoutes {
    case close
}

internal protocol ModalPickerRouterProtocol: AnyObject {
    func navigate(_ route: ModalPickerRoutes)
}

internal final class ModalPickerRouter {
    weak var viewController: ModalPickerController?
    
    static func createModule(
        _ collection: [String],
        config: ModalPickerConfig?
    ) -> ModalPickerController {
        let view = ModalPickerController()
        let router = ModalPickerRouter()
        let interactor = ModalPickerInteractor(
            configData: config
        )
        let presenter = ModalPickerPresenter(
            view: view,
            interactor: interactor,
            router: router
        )
        presenter.collection = collection
        view.presenter = presenter
        router.viewController = view
        return view
    }
}

extension ModalPickerRouter: ModalPickerRouterProtocol {
    func navigate(_ route: ModalPickerRoutes) {
        switch route {
        case .close:
            viewController?.dismiss(animated: true)
        }
    }
    
    
}
