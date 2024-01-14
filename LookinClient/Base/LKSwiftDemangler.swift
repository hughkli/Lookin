//
//  LKSwiftDemangler.swift
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

import Foundation

public class LKSwiftDemangler: NSObject {
    private static var cache: [String:String] = [:]
    
    @objc public static func parse(input: String) -> String {
        if let cachedResult = cache[input] {
            return cachedResult
        }
        let result: String
        do {
            let swiftSymbol = try parseMangledSwiftSymbol(input)
            result = swiftSymbol.print(using:
               SymbolPrintOptions.default.union(.synthesizeSugarOnTypes))
        } catch _ {
            result = input
        }
        cache[input] = result
        return result
    }
}
