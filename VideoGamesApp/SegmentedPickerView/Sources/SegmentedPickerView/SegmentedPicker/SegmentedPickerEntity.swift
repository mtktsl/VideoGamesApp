//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation
import UIKit

public struct SegmentedPickerConfig {
    
    let segmentedFilters: [String]?// = nil
    let moreFilters: [String]?// = nil
    let moreButtonTitle: String// = "More"
    let moreButtonImage: UIImage?// = nil
    let pickerTitle: String// = "Select Filter"
    let modalConfig: ModalPickerConfig?
    
    init(
        segmentedFilters: [String]?,
        moreFilters: [String]?,
        moreButtonTitle: String,
        moreButtonImage: UIImage?,
        pickerTitle: String,
        modalConfig: ModalPickerConfig?
    ) {
        self.segmentedFilters = segmentedFilters
        self.moreFilters = moreFilters
        self.moreButtonTitle = moreButtonTitle
        self.moreButtonImage = moreButtonImage
        self.pickerTitle = pickerTitle
        self.modalConfig = modalConfig
    }
}
