//
//  ModalPickerInteractor.swift
//  
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import Foundation

protocol ModalPickerInteractorProtocol: AnyObject {
    var config: ModalPickerConfig? { get }
}

final class ModalPickerInteractor {
    var configData: ModalPickerConfig?
    init(configData: ModalPickerConfig? = nil) {
        self.configData = configData
    }
}

extension ModalPickerInteractor: ModalPickerInteractorProtocol {
    var config: ModalPickerConfig? {
        return configData
    }
}
