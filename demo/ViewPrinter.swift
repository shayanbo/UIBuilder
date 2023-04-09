//
//  ViewPrinter.swift
//  demo
//
//  Created by shayanbo on 2023/4/7.
//

import Foundation
import YogaKit
import SwiftyXMLParser

class ViewPrinter {
    
    func build(from xmlString: String) -> UIView? {
        
        guard let data = xmlString.data(using: .utf8) else { return nil }
        let xml = XML.parse(data)
        guard let root = xml.first.element?.childElements.first else { return nil }
        return build0(root)
    }
    
    private func build0(_ e: XML.Element) -> UIView? {
        
        guard let clazz = NSClassFromString(e.name) as? NSObject.Type else { return nil }
        let object = clazz.init()
        guard let view = object as? UIView else { return nil }
        
        view.yoga.isEnabled = true
        
        /// attributes
        for attribute in e.attributes {

            /// tranform property
            var parts = attribute.key.components(separatedBy: "-")
            parts = parts.enumerated().map { (index, part) in
                index != 0 ? part.capitalized : part
            }
            let property = parts.joined(separator: "")

            /// transform setter
            parts = parts.map { $0.capitalized }
            parts.insert("set", at: 0)
            parts.append(":")
            let setter = parts.joined(separator: "")
            let setMethod = NSSelectorFromString(setter)

            /// map value
            var value: Any? = nil
            if let mapper = PropertyHandler.shared["\(e.name).\(property)"]
                ?? PropertyHandler.shared[property] {
                value = mapper(attribute.value)
                if value == nil {
                    continue /// drop if mapper return nil
                }
            } else {
                value = attribute.value
            }

            /// view.yoga -> view -> view.layer
            if view.yoga.responds(to: setMethod) {
                view.yoga.setValue(value, forKey: property)
            } else if view.responds(to: setMethod) {
                view.setValue(value, forKey: property)
            } else if view.layer.responds(to: setMethod) {
                view.layer.setValue(value, forKey: property)
            } else {
                /// predefined action
                var mapper = ActionHandler.shared["\(e.name).\(property)"]
                mapper = mapper ?? ActionHandler.shared[property]
                mapper?(view, e.attributes)
            }
        }
        
        /// children
        if !e.childElements.isEmpty {
            for childElement in e.childElements {
                if let child = build0(childElement) {
                    view.addSubview(child)
                    
                    /// calculate the content size according to the  first child view
                    if let scrollView = view as? UIScrollView {
                        child.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: [.flexibleWidth, .flexibleHeight])
                        print(child.bounds.size)
                        scrollView.contentSize = child.bounds.size
                    }
                }
            }
        }
        
        return view
    }
}
