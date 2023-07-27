//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation

internal protocol ModalPickerPresenterProtocol {
    
    var itemCount: Int { get }
    var isFiltering: Bool { get }
    
    func viewDidLoad()
    func viewDidLayout()
    func onItemSelected(at index: Int)
    func onSearch(_ searchText: String)
    func getFilter(at index: Int) -> String?
    func onCancelTap()
    func onDisappear()
    func onReturnTap()
}

internal final class ModalPickerPresenter {
    unowned var view: ModalPickerControllerProtocol!
    let router: ModalPickerRouterProtocol!
    let interactor: ModalPickerInteractorProtocol!
    
    var collection = [String]()
    var filteredCollection = [String]()
    var selectedFilter: String?
    
    var isFiltering: Bool = false
    
    internal init(
        view: ModalPickerControllerProtocol,
        interactor: ModalPickerInteractorProtocol!,
        router: ModalPickerRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension ModalPickerPresenter: ModalPickerPresenterProtocol {
    func onReturnTap() {
        view.endEditting()
    }
    
    func onDisappear() {
        if let selectedFilter {
            view.sendToDelegate(selectedFilter)
        }
    }
    
    func onCancelTap() {
        router.navigate(.close)
    }
    
    func getFilter(at index: Int) -> String? {
        if index >= itemCount || index < 0 {
            return nil
        } else {
            return isFiltering
            ? filteredCollection[index]
            : collection[index]
        }
    }
    
    var itemCount: Int {
        isFiltering
        ? filteredCollection.count
        : collection.count
    }
    
    
    func viewDidLoad() {
        view.setupView()
        view.setupColors(
            viewColor: interactor.config?.viewColor ?? .white,
            titleTextColor: interactor.config?.titleTextColor ?? .black,
            tableColor: interactor.config?.tableColor ?? .clear,
            cellColor: interactor.config?.cellColor ?? .clear,
            cellTextColor: interactor.config?.cellTextColor ?? .black,
            searchColor: interactor.config?.searchColor ?? .systemGray5,
            searchTextColor: interactor.config?.searchTextColor ?? .black,
            cancelColor: interactor.config?.cancelColor ?? .systemRed,
            cancelTextColor: interactor.config?.cancelTextColor ?? .white
        )
    }
    
    func viewDidLayout() {
        view.layoutViews()
    }
    
    func onSearch(_ searchText: String) {
        filteredCollection = collection.filter({ $0.contains(searchText) })
        isFiltering = !searchText.isEmpty
        view.reloadData()
    }
    
    func onItemSelected(at index: Int) {
        selectedFilter = getFilter(at: index)
        router.navigate(.close)
    }
    
}
