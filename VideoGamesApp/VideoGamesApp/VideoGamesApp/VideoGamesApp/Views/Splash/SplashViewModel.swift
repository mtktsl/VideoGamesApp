//
//  SplashViewModell.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation
import NetworkStatusObserver

extension SplashViewModel {
    fileprivate enum Constants {
        static let internetTimerInterval: TimeInterval = 1
    }
}

protocol SplashViewModelProtocol: AnyObject {
    var imageAssetName: String { get }
    func checkInternetConnection()
}

final class SplashViewModel {
    private(set) weak var coordinator: MainCoordinator?
    
    private var connectionTimer: Timer?
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
}

extension SplashViewModel: SplashViewModelProtocol {
    
    var imageAssetName: String {
        return ApplicationConstants.ImageAssets.rawg_logo
    }
    
    func checkInternetConnection() {
        
        connectionTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.internetTimerInterval,
            repeats: true
        ) { [weak self] timer in
            guard let self else { return }
            if NetworkStatusObserver.shared.isConnected {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    coordinator?.navigate(to: .main)
                }
                connectionTimer?.invalidate()
            }
        }
    }
}
