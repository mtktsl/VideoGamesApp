//
//  ImageViewPagerReusableViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 17.07.2023.
//

import Foundation
import RAWG_API

protocol ImageViewPagerReusableViewModelDelegate: AnyObject {
    func onImageSuccess(
        _ data: Data,
        for index: Int
    )
    func onImageError(for index: Int)
}

protocol ImageViewPagerReusableViewModelProtocol {
    var delegate: ImageViewPagerReusableViewModelDelegate? { get set }
    var imageURLStrings: [String?] { get }
    var titles: [String?] { get }
    
    func downloadImages()
}

final class ImageViewPagerReusableViewModel {
    
    let service = RAWG_GamesService.shared
    
    weak var delegate: ImageViewPagerReusableViewModelDelegate?
    
    var imageURLStrings = [String?]()
    var titles = [String?]()
    
    init(
        imageURLStrings: [String?],
        titles: [String?]
    ) {
        self.imageURLStrings = imageURLStrings
        self.titles = titles
    }
}

extension ImageViewPagerReusableViewModel: ImageViewPagerReusableViewModelProtocol {
    
    func downloadImages() {
        
        for (index, urlString) in imageURLStrings.enumerated() {
            guard let urlString else { continue }
            
            service.donwloadImage(urlString) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    delegate?.onImageSuccess(data, for: index)
                case .failure(_):
                    delegate?.onImageError(for: index)
                }
            }
        }
    }
}
