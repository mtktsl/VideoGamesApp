//
//  Bundle+Extension.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(type: T.Type, file: String) throws -> T {
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Fail \(file)")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file)")
        }
        
        let decoder = JSONDecoder()
        
        guard let contents = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file)")
        }
        
        return contents
    }
    
    func jsonDecode<D>(
        decodeType: D.Type,
        file: String,
        extenstion: String
    ) throws -> D where D: Decodable {
        
        let fileName = "\(file).\(extenstion)"
        guard let pathString = path(forResource: file, ofType: extenstion) else {
            fatalError("\(fileName) not found")
        }

        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            fatalError("Unable to convert \(file).\(extenstion) to String")
        }

        //print("The JSON string is: \(jsonString)")

        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("Unable to convert \(file).\(extenstion) to Data")
        }
        
        guard let result = try? JSONDecoder().decode(decodeType, from: jsonData)
        else {
            fatalError("Unable to decode \(file).\(extenstion) to type \(decodeType)")
        }

        /*guard let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] else {
            fatalError("Unable to convert \(file).\(extenstion) to JSON dictionary")
        }*/

        //print("The JSON dictionary is: \(jsonDictionary)")
        return result
    }
}

