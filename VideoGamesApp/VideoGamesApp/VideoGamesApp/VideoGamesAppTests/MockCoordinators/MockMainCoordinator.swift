//
//  MockMainCoordinator.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation
@testable import VideoGamesApp
import UIKit

final class MockMainCoordinator: MainCoordinatorProtocol {
    
    
    var invokeCountCheckInternet: Int = 0
    func checkInternetConnection() {
        invokeCountCheckInternet += 1
    }
    
    var invokeCountNavigate: Int = 0
    func navigate(to: VideoGamesApp.MainCoordinator.Route) {
        invokeCountNavigate += 1
    }
    
    var invokeCountPopUpAlert: Int = 0
    func popUpAlert(title: String, message: String, okOption: String?, cancelOption: String?, onOk: ((UIAlertAction) -> Void)?, onCancel: ((UIAlertAction) -> Void)?) {
        onOk?(UIAlertAction())
        //onCancel?(UIAlertAction())
        invokeCountPopUpAlert += 1
    }
    
    
}
