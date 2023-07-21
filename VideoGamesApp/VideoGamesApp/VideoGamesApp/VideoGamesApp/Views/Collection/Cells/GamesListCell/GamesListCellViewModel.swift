//
//  GamesListCellViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation
import RAWG_API

protocol GamesListCellViewModelDelegate: AnyObject {
    func onImageResult(_ imageData: Data)
    func onImageError(_ error: RAWG_NetworkError)
}

protocol GamesListCellViewModelProtocol {
    var dataModel: RAWG_GamesListModel? { get }
    var delegate: GamesListCellViewModelDelegate? { get set }
    
    var rawgRating: GamesListCellRatingModel { get }
    var metacriticRating: GamesListCellRatingModel { get }
    
    func downloadGameImage()
}

final class GamesListCellViewModel {
    private(set) var dataModel: RAWG_GamesListModel?
    weak var delegate: GamesListCellViewModelDelegate?
    
    init(dataModel: RAWG_GamesListModel?) {
        self.dataModel = dataModel
    }
}

extension GamesListCellViewModel: GamesListCellViewModelProtocol {
    var rawgRating: GamesListCellRatingModel {
        
        guard let rating = dataModel?.rating,
              rating != 0
        else { return .none }
        
        if rating < 2.5 {
            return .low
        } else if rating < 3.75 {
            return .medium
        } else {
            return .high
        }
    }
    
    var metacriticRating: GamesListCellRatingModel {
        guard let rating = dataModel?.metacritic
        else { return .none }
        
        if rating < 50 {
            return .low
        } else if rating < 75 {
            return .medium
        } else {
            return .high
        }
    }
    
    func downloadGameImage() {
        guard let urlString = dataModel?.backgroundImageURLString
        else {
            delegate?.onImageError(.urlError)
            return
        }
        RAWG_GamesService.shared.downloadImage(
            urlString) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    delegate?.onImageResult(data)
                case .failure(let error):
                    delegate?.onImageError(error)
                }
            }
    }
}
