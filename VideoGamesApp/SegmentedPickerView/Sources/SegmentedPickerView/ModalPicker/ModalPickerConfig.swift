//
//  ModalPickerEntity.swift
//  
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import UIKit

public struct ModalPickerConfig {
    public let viewColor: UIColor
    public let titleTextColor: UIColor
    public let tableColor: UIColor
    public let cellColor: UIColor
    public let cellTextColor: UIColor
    public let searchColor: UIColor
    public let searchTextColor: UIColor
    public let cancelColor: UIColor
    public let cancelTextColor: UIColor
    
    public init(
        viewColor: UIColor,
        titleTextColor: UIColor,
        tableColor: UIColor,
        cellColor: UIColor,
        cellTextColor: UIColor,
        searchColor: UIColor,
        searchTextColor: UIColor,
        cancelColor: UIColor,
        cancelTextColor: UIColor
    ) {
        self.viewColor = viewColor
        self.titleTextColor = titleTextColor
        self.tableColor = tableColor
        self.cellColor = cellColor
        self.cellTextColor = cellTextColor
        self.searchColor = searchColor
        self.searchTextColor = searchTextColor
        self.cancelColor = cancelColor
        self.cancelTextColor = cancelTextColor
    }
}
