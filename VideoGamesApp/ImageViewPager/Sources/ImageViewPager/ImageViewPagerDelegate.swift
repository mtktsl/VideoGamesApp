//
//  ImageViewPagerDelegate.swift
//  
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation

public protocol ImageViewPagerDelegate: AnyObject {
    func onImageTap(
        imageViewPager: ImageViewPager,
        at index: Int
    )
}
