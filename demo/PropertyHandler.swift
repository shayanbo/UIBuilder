//
//  PropertyMapping.swift
//  demo
//
//  Created by shayanbo on 2023/4/7.
//

import UIKit
import YogaKit

class PropertyHandler {
    
    static var shared: PropertyHandler = { PropertyHandler() }()
    
    typealias Mapper = (String) -> Any?
    private var mappers = [String: Mapper]()
    
    subscript(_ key: String) -> (Mapper)? {
        set { mappers[key] = newValue }
        get { mappers[key] }
    }
    
    init() {
        registerLayerMappers()
        registerYogaMappers()
        registerUIViewMappers()
        registerBuiltinViewMappers()
    }
}

extension PropertyHandler {
    
    func registerBuiltinViewMappers() {
        
        self["UIImageView.image"] = Self.imageMapper
        
        self["UIScrollView.pagingEnabled"] = Self.boolMapper
        
        self["UILabel.textAlignment"] = { value in
            Self.enumMapper([
                "left", "center", "right", "justified", "natural"
            ])(value)
        }
        
        self["UILabel.textColor"] = Self.colorMapper
        self["UILabel.font"] = Self.fontMapper
    }
    
    func registerLayerMappers() {
        
        self["backgroundColor"] = Self.colorMapper
        self["cornerRadius"] = Self.floatMapper
        self["borderWidth"] = Self.floatMapper
        self["borderColor"] = Self.cgColorMapper
    }
    
    func registerUIViewMappers() {
        
        self["tag"] = { Int($0) }
        
        self["userInteractionEnabled"] = Self.boolMapper
        
        self["clipsToBounds"] = Self.boolMapper
        
        self["tintColor"] = Self.colorMapper
        
        self["contentMode"] = { value in
            Self.enumMapper([
                "scale-to-fill", "scale-aspect-fit", "scale-aspect-fill", "redraw", "center", "top", "bottom", "left", "right", "top-left", "top-right", "bottom-left", "bottom-right"
            ])(value)
        }
    }
    
    func registerYogaMappers() {
        
        self["flexDirection"] = { value in
            Self.enumMapper([
                "column", "column-reverse", "row", "row-reverse"
            ])(value)
        }
        
        self["alignItems"] = Self.alignMapper
        self["alignContent"] = Self.alignMapper
        self["alignSelf"] = Self.alignMapper
        
        self["justifyContent"] = { value in
            Self.enumMapper([
                "flex-start", "center", "flex-end", "space-between", "space-around", "space-evenly"
            ])(value)
        }
        
        self["flexWrap"] = { value in
            Self.enumMapper([
                "no-wrap", "wrap", "wrap-reverse"
            ])(value)
        }
        
        self["overflow"] = { value in
            Self.enumMapper([
                "visible", "hidden", "scroll"
            ])(value)
        }
        
        self["direction"] = { value in
            Self.enumMapper([
                "inherit", "ltr", "rtl"
            ])(value)
        }
        
        self["position"] = { value in
            Self.enumMapper([
                "relative", "absolute"
            ])(value)
        }
        
        self["left"] = Self.pointMapper
        self["top"] = Self.pointMapper
        self["right"] = Self.pointMapper
        self["bottom"] = Self.pointMapper
        self["start"] = Self.pointMapper
        self["end"] = Self.pointMapper
        
        self["marginBottom"] = Self.pointMapper
        self["marginTop"] = Self.pointMapper
        self["marginLeft"] = Self.pointMapper
        self["marginRight"] = Self.pointMapper
        self["marginStart"] = Self.pointMapper
        self["marginEnd"] = Self.pointMapper
        self["marginHorizontal"] = Self.pointMapper
        self["marginVertical"] = Self.pointMapper
        self["margin"] = Self.pointMapper
        
        self["paddingLeft"] = Self.pointMapper
        self["paddingTop"] = Self.pointMapper
        self["paddingRight"] = Self.pointMapper
        self["paddingBottom"] = Self.pointMapper
        self["paddingStart"] = Self.pointMapper
        self["paddingEnd"] = Self.pointMapper
        self["paddingHorizontal"] = Self.pointMapper
        self["paddingVertical"] = Self.pointMapper
        self["padding"] = Self.pointMapper
        
        self["width"] = Self.pointMapper
        self["height"] = Self.pointMapper
        
        self["flexShrink"] = Self.floatMapper
        self["flexGrow"] = Self.floatMapper
        self["aspectRatio"] = Self.floatMapper
    }
}

extension PropertyHandler {
    
    static var boolMapper: Mapper = { value in
       if value == "true" || value == "TRUE" || value == "YES" || value == "yes" || value == "y" {
           return true
       } else if value == "false" || value == "FALSE" || value == "NO" || value == "no" || value == "n" {
           return false
       } else {
           return nil
       }
    }
    
    static var pointMapper: Mapper = { value in
        var objcType = "{YGValue=fi}"
        let percent = value.hasSuffix("%")
        if percent {
            let percentage = value[..<value.index(before: value.endIndex)]
            var v = (Float(percentage) ?? 0)%
            return NSValue(&v, withObjCType: &objcType)
        } else {
            var v = YGValue(floatLiteral: Float(value) ?? 0)
            return NSValue(&v, withObjCType: &objcType)
        }
    }
    
    static var colorMapper: Mapper = { value in
        
        let propertyName = value.components(separatedBy: "-").enumerated().map { (index, segment) in
            index == 0 ? segment : segment.capitalized
        }.joined(separator: "")
        let getter = NSSelectorFromString("\(propertyName)Color")
        
        if UIColor.responds(to: getter) {
            return UIColor.perform(getter).takeUnretainedValue()
        } else {
            return UIColor(hexColor: value)
        }
    }
    
    static var cgColorMapper: Mapper = { value in
        (colorMapper(value) as? UIColor)?.cgColor
    }
    
    static var fontMapper: Mapper = { value in
        
        var pairs = [String: String]()
        value.components(separatedBy: ";").forEach { pair in
            let item = pair.components(separatedBy: ":")
            guard item.count == 2 else { return }
            
            let name = item[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = item[1].trimmingCharacters(in: .whitespacesAndNewlines)
            pairs[name] = value
        }
        
        guard let sizeRep = pairs["size"], let size = Double(sizeRep) else { return nil }
        
        if let family = pairs["family"] {
            return UIFont(name: family, size: size)
        } else if let weight = pairs["weight"] {
            let w: UIFont.Weight
            switch weight {
            case "ultra-light": w = .ultraLight
            case "thin": w = .thin
            case "light": w = .light
            case "regular": w = .regular
            case "medium": w = .medium
            case "semibold": w = .semibold
            case "bold": w = .bold
            case "heavy": w = .heavy
            case "black": w = .black
            default: w = .regular
            }
            return UIFont.systemFont(ofSize: size, weight: w)
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    static var floatMapper: Mapper = { value in
        Double(value)
    }
    
    static var alignMapper: Mapper = { value in
        switch value {
        case "auto" : return 0
        case "start" : return 1
        case "center" : return 2
        case "flex-end" : return 3
        case "stretch" : return 4
        case "baseline" : return 5
        case "space-between" : return 6
        case "space-around" : return 7
        default: return nil
        }
    }
    
    static func enumMapper(_ enums: [String]) -> Mapper {
        { enums.firstIndex(of: $0) }
    }
    
    static var imageMapper: Mapper = { value in
        if value.contains(":") {
            let pair = value.components(separatedBy: ":")
            if pair.count == 2 {
                if pair[0] == "asset" || pair[0] == "assets" {
                    return UIImage(named: pair[1])
                } else if pair[0] == "symbol" {
                    return UIImage(systemName: pair[1])
                }
            }
        }
        return UIImage(named: value)
    }
}
