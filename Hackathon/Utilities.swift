//
//  Utilities.swift
//  Hackathon
//
//  Created by Wojciech Tyziniec on 20/11/15.
//  Copyright © 2015 Wojciech Tyziniec. All rights reserved.
//

import Foundation

class Utilities: NSObject {


    /**
     Funkcja wypisuje nam jsona jako string
     
     - parameter value:         przygotowany obiekt json
     - parameter prettyPrinted: wartosc ustawien, czy chcemy zeby wypisalo nam z lamaniem wierszy
     
     - returns: zwraca stringa z jsona
     */
    func JSONStringify(value: AnyObject, prettyPrinted:Bool = false) -> String {
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        if NSJSONSerialization.isValidJSONObject(value) {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            } catch {
                print("error")
                
            }
        }
        return ""
    }
    
    
}
