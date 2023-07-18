//
//  ImageViewPagerReusableView.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 16.07.2023.
//

import UIKit
import ImageViewPager
import NSLayoutConstraintExtensionPackage

final class ImageViewPagerReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "ImageViewPagerReusableView"
    
    var contentInset: UIEdgeInsets = .zero
    
    var viewModel: ImageViewPagerReusableViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            setupImageViewPager()
            viewModel.downloadImages()
        }
    }
    
    let imageViewPager: ImageViewPager = {
        let imageViewPager = ImageViewPager([])
        
        imageViewPager.scrollView.layer.cornerRadius = 10
        return imageViewPager
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageViewPager)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewPager.frame = bounds.inset(by: contentInset)
    }
    
    //The reason we create a seperate swipecontainer array insance is that to prevent imageViewPager to redraw it's views every single time we append a new container info
    //So we collect the containermodel objects first then set imageViewPager once
    private func setupImageViewPager() {
        var swipeContainers = [SwipeContainerModel]()
        for title in viewModel.titles {
            swipeContainers.append(
                .init(
                    image: UIImage(named: ApplicationConstants.ImageAssets.loading),
                    title: title
                )
            )
        }
        
        imageViewPager.swipeContainers = swipeContainers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageViewPagerReusableView: ImageViewPagerReusableViewModelDelegate {
    func onImageSuccess(_ data: Data, for index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageViewPager.imageViews[index].image = UIImage(data: data)
        }
    }
    
    func onImageError(for index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageViewPager.imageViews[index].image = UIImage(
                systemName: ApplicationConstants.SystemImages.exclamationmarkTriangle
            )
        }
    }
}
