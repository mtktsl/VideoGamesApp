//
//  Bundle+Extension.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation

extension Bundle {
    
    func jsonDecode<T>(
        decodeType: T.Type,
        file: String,
        extenstion: String
    ) throws -> T where T: Decodable {
        
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

        return result
    }
}

