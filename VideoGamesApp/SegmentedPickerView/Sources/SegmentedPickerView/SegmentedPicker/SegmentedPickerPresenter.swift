//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation

internal protocol SegmentedPickerPresenterProtocol {
    func viewDidInit()
    func onSegmentChanged()
    func onMoreButtonTap()
}

internal final class SegmentedPickerPresenter {
    
    unowned var view: SegmentedPickerViewProtocol!
    let router: SegmentedPickerRouterProtocol!
    let interactor: SegmentedPickerInteractorProtocol!
    
    init(view: SegmentedPickerViewProtocol!, router: SegmentedPickerRouterProtocol!, interactor: SegmentedPickerInteractorProtocol!) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension SegmentedPickerPresenter: SegmentedPickerPresenterProtocol {
    
    func onMoreButtonTap() {
        let config = interactor.getConfig()
        router.presentPicker(
            config?.moreFilters ?? [],
            pickerTitle: config?.pickerTitle ?? "Select Filter",
            config: config?.modalConfig
        )
    }
    
    func onSegmentChanged() {
        let config = interactor.getConfig()
        view.changeSegment(
            config?.segmentedFilters ?? [],
            buttonTitle: config?.moreButtonTitle ?? "More"
        )
    }
    
    func viewDidInit() {
        let config = interactor.getConfig()
        view.setupMoreButton(
            title: config?.moreButtonTitle ?? "More",
            image: config?.moreButtonImage
        )
        view.setupSegmentedControl()
        view.setupInitialValue(config?.segmentedFilters?.first ?? nil)
        let isMoreButtonActive = config?.moreFilters != nil
        view.setupMainGrid(isMoreButtonActive)
    }
}
