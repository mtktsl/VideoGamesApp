//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation
import UIKit

internal protocol SegmentedPickerRouterProtocol {
    func presentPicker(
        _ filters: [String],
        pickerTitle: String,
        config: ModalPickerConfig?
    )
}

internal final class SegmentedPickerRouter {
    
    weak var controllerView: SegmentedPickerView?
    
    static func createModule(
        _ config: SegmentedPickerConfig
    ) -> SegmentedPickerView {
        let view = SegmentedPickerView(config)
        let interactor = SegmentedPickerInteractor()
        let router = SegmentedPickerRouter()
        let presenter = SegmentedPickerPresenter(
            view: view,
            router: router,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.config = config
        router.controllerView = view
        
        return view
    }
}

extension SegmentedPickerRouter: SegmentedPickerRouterProtocol {
    func presentPicker(
        _ filters: [String],
        pickerTitle: String,
        config: ModalPickerConfig?
    ) {
        let pickerVC = ModalPickerRouter.createModule(
            filters,
            config: config
        )
        
        pickerVC.delegate = controllerView
        pickerVC.horizontalInset = 10
        pickerVC.height = controllerView?.pickerHeight ?? 0
        pickerVC.modalPresentationStyle = .formSheet
        pickerVC.titleLabel.text = pickerTitle
        //pickerVC.cancelButton.backgroundColor = controllerView?.popupCancelColor ?? .gray
        controllerView?
            .window?
            .rootViewController?
            .present(pickerVC, animated: true)
    }
}
