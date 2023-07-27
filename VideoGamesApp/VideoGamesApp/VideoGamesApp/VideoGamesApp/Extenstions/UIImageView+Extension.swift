//
//  UIImageView+Extension.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import UIKit

extension UIImageView {
    func setImageAsync(
        _ newImage: UIImage?,
        newContentMode: UIView.ContentMode = .scaleToFill
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            image = newImage
            contentMode = newContentMode
        }
    }
}
