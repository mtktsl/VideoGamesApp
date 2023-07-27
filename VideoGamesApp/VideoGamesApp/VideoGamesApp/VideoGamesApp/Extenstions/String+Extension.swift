//
//  String+Extension.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import Foundation

extension String {
    func firstUpperCased() -> String {
        var copy = String(self)
        if copy.isEmpty { return self }
        let first = copy.remove(at: copy.startIndex)
        return first.uppercased() + copy.lowercased()
    }
}
