//
//  UIEdgeInsets+Extension.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

extension UIEdgeInsets {
    init(_ inset: CGFloat) {
        self.init(
            top: inset,
            left: inset,
            bottom: inset,
            right: inset
        )
    }
}
