//
//  MainViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation

protocol MainViewModelProtocol: AnyObject {
    var tabbarImages: [String] { get }
    var badgeTabBarIndex: Int { get }
    func fetchCoreData()
}

final class MainViewModel {
    
    typealias appConst = ApplicationConstants
    
    private let imageNames: [String] = [
        appConst.SystemImages.gameController,
        appConst.SystemImages.heart
    ]
}

extension MainViewModel: MainViewModelProtocol {
    
    var tabbarImages: [String] {
        return imageNames
    }
    
    var badgeTabBarIndex: Int {
        return 1
    }
    
    func fetchCoreData() {
        CoreDataManager.shared.fetchLatestUpdates()
    }
}
