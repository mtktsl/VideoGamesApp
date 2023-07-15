//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation
import UIKit

public struct SwipeContainerModel {
    public let image: UIImage?
    public let title: String?
    
    public init(
        image: UIImage?,
        title: String? = nil
    ) {
        self.image = image
        self.title = title
    }
}
