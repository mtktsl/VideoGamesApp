//
//  BasicCache.swift
//  
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation

internal protocol BasicCacheProtocol {
    
}

internal final class BasicCache<K: Equatable, V> {
    var cacheArray: [ (key: K, value: V) ] = []
    private var capacity: Int
    
    public init(capacity: Int) {
        self.capacity = capacity
    }
    
    public func cache(_ pair: (key: K, value: V)) {
        cacheArray.insert(pair, at: 0)
        if cacheArray.count > capacity {
            _ = cacheArray.popLast()
        }
    }
    
    public func get(_ key: K) -> V? {
        if let result = cacheArray.first(where: { $0.key == key })?.value {
            remove(key)
            cacheArray.insert((key: key, value: result), at: 0)
            return result
        } else {
            return nil
        }
    }
    
    private func remove(_ key: K) {
        cacheArray.removeAll(where: { key == $0.key })
    }
}
