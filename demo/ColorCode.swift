//
//  ColorCode.swift
//  demo
//
//  Created by shayanbo on 2023/4/8.
//

import UIKit

class ColorCode {
    
    private var rules: NSArray
    
    init?() {
        guard let colorCodePath = Bundle.main.path(forResource: "color-code", ofType: "plist") else { return nil }
        guard let rules = NSArray(contentsOfFile: colorCodePath) else { return nil }
        for rule in rules {
            guard let rule = rule as? Dictionary<String, String> else { return nil }
            guard rule["regex"] != nil else { return nil }
            guard rule["color"] != nil else { return nil }
        }
        self.rules = rules
    }
    
    func render(_ str: String) -> NSAttributedString? {
        
        let attributedStr = NSMutableAttributedString(string: str)
        attributedStr.addAttributes([.foregroundColor : UIColor.white], range: NSRange(location: 0, length: str.count))
        attributedStr.addAttributes([.font : UIFont.systemFont(ofSize: 20, weight: .semibold)], range: NSRange(location: 0, length: str.count))
        
        rules.forEach { rule in
            guard let rule = rule as? Dictionary<String, String> else { return }
            guard let regex = rule["regex"] else { return }
            guard let color = rule["color"] else { return }
            
            let expr = try? NSRegularExpression(pattern: regex)
            let exprResults = expr?.matches(in: str, range: NSRange(location: 0, length: str.count))
            exprResults?.forEach({ result in
                attributedStr.addAttributes([.foregroundColor : UIColor(hexColor: color) ?? UIColor.white, .font : UIFont.systemFont(ofSize: 20, weight: .semibold)], range: result.range)
            })
        }
        
        return attributedStr
    }
}
