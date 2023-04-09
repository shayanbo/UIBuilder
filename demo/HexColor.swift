//
//  Color+Hex.swift
//  demo
//
//  Created by shayanbo on 2023/4/7.
//

import UIKit

extension UIColor {
    
    convenience init?(hexColor: String) {
        
        var currentHexColor = hexColor[hexColor.startIndex..<hexColor.endIndex]

        guard hexColor.hasPrefix("#") else { return nil }
        guard hexColor.count == 9 else { return nil }
        for (index, char) in hexColor.enumerated() {
            if index != 0 {
                guard "1234567890ABCDEFabcdef".contains(char) else { return nil }
            }
        }
        
        let index: (Int) -> String.Index = { i in
            currentHexColor.index(currentHexColor.startIndex, offsetBy: i)
        }

        /// remove #
        currentHexColor = currentHexColor[currentHexColor.index(currentHexColor.startIndex, offsetBy: 1)...]

        var red:UInt64 = 0, green:UInt64 = 0, blue:UInt64 = 0, alpha:UInt64 = 0
        
        Scanner(string: String(currentHexColor[index(0)..<index(2)])).scanHexInt64(&red)
        Scanner(string: String(currentHexColor[index(2)..<index(4)])).scanHexInt64(&green)
        Scanner(string: String(currentHexColor[index(4)..<index(6)])).scanHexInt64(&blue)
        Scanner(string: String(currentHexColor[index(6)..<index(8)])).scanHexInt64(&alpha)

        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }

}
