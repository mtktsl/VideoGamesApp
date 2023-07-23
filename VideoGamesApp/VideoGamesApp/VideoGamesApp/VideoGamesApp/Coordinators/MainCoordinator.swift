//
//  MainCoordinator.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit
import RAWG_API
import NetworkStatusObserver

extension MainCoordinator {
    enum Route {
        case main
        case detail(gameID: Int)
        case back
    }
}

protocol MainCoordinatorProtocol: AnyObject {
    func checkInternetConnection()
    func navigate(to: MainCoordinator.Route)
    
    func popupError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    )
}

final class MainCoordinator: CoordinatorProtocol {
    
    var childCoordinators = [CoordinatorProtocol]()
    
    var isPopupOpen = false
    
    var navigationController: UINavigationController?
    
    var appDelegate: AppDelegate?
    
    init(
        navigationController: UINavigationController? = nil,
        appDelegate: AppDelegate? = nil
    ) {
        self.navigationController = navigationController
        self.appDelegate = appDelegate
        NetworkStatusObserver.shared.delegates.append(.init(self))
        NetworkStatusObserver.shared.startObserving()
    }
}

//MARK: - function implementations -
extension MainCoordinator {
    
    func navigateToMain() {
        
        let mainVC = MainViewController()
        mainVC.viewModel = MainViewModel()
        
        let homeVC = HomeViewController()
        homeVC.viewModel = HomeViewModel(
            coordinator: self,
            service: RAWG_GamesService.shared
        )
        
        let favoritesVC = FavoritesViewController()
        favoritesVC.viewModel = FavoritesViewModel(
            coordinator: self
        )
        
        mainVC.setViewControllers(
            [
                homeVC,
                favoritesVC
            ],
            animated: false
        )
        
        navigationController?.setViewControllers([mainVC], animated: true)
    }
    
    func navigateToDetail(_ gameID: Int) {
        let detailVC = DetailViewController()
        detailVC.viewModel = DetailViewModel(
            service: RAWG_GamesService.shared,
            coordinator: self,
            gameID: gameID
        )
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func start() {
        let splashVC = SplashViewController()
        splashVC.viewModel = SplashViewModel(
            coordinator: self
        )
        navigationController?.setViewControllers([splashVC], animated: true)
    }
    
    func checkInternetConnection() {
        onConnectionChanged(NetworkStatusObserver.shared.isConnected)
    }
    
    func selectNavigation(_ route: Route) {
        switch route {
        case .main:
            navigateToMain()
        case .detail(let gameID):
            navigateToDetail(gameID)
        case .back:
            navigationController?.popViewController(animated: true)
        }
    }
}

extension MainCoordinator: MainCoordinatorProtocol {
    
    func navigate(to route: Route) {
        
        if isPopupOpen {
            Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true
                
            ) { [weak self] timer in
                guard let self else { return }
                
                if !isPopupOpen {
                    timer.invalidate()
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        selectNavigation(route)
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                selectNavigation(route)
            }
        }
    }
}

extension MainCoordinator: NetworkStatusObserverDelegate {
    
    func onConnectionChanged(_ isConnected: Bool) {
        
        if !isConnected && !isPopupOpen {
            
            isPopupOpen = true

            DispatchQueue.main.async { [weak self] in
                self?.popupError(
                    title: "Connection Error",
                    message: "There is no internet connection.",
                    okOption: "Retry",
                    cancelOption: nil,
                    
                    onOk: { [weak self] _ in
                        guard let self else { return }
                        
                        isPopupOpen = false
                        checkInternetConnection()
                        
                    },
                    onCancel: nil
                )
            }
        }
    }
}
