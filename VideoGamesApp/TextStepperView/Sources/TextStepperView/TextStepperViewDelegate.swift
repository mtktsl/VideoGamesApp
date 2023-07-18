//
//  TextStepperViewDelegate.swift
//  
//
//  Created by Metin Tarık Kiki on 17.07.2023.
//

import Foundation

public protocol TextStepperViewDelegate: AnyObject {
    func onCurrentValueChange(
        _ textStepperView: TextStepperView,
        oldValue: Int,
        newValue: Int
    )
}
