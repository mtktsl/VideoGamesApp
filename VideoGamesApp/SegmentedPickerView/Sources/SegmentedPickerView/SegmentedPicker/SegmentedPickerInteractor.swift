//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation

internal protocol SegmentedPickerInteractorProtocol: AnyObject {
    func getConfig() -> SegmentedPickerConfig?
}

internal final class SegmentedPickerInteractor {
    var config: SegmentedPickerConfig?
}

extension SegmentedPickerInteractor: SegmentedPickerInteractorProtocol {
    func getConfig() -> SegmentedPickerConfig? {
        return config
    }
}
