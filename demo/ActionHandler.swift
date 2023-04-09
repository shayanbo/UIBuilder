//
//  PropertyMapping.swift
//  demo
//
//  Created by shayanbo on 2023/4/7.
//

import UIKit
import YogaKit
import SDWebImage
import RxCocoa

class ActionHandler {
    
    static var shared: ActionHandler = { ActionHandler() }()
    
    typealias Mapper = (UIView, [String: String]) -> Void
    private var mappers = [String: Mapper]()
    
    subscript(_ key: String) -> (Mapper)? {
        set { mappers[key] = newValue }
        get { mappers[key] }
    }
    
    init() {
        self["UIImageView.url"] = { view, attributes in
            guard let imageView: UIImageView = view as? UIImageView else { return }
            imageView.sd_setImage(with: URL(string: attributes["url"] ?? ""), placeholderImage: UIImage(named: attributes["placeholder"] ?? ""), context: nil)
        }
        self["link"] = { view, attributes in
            let tap = UITapGestureRecognizer()
            _ = tap.rx.event.take(until: view.rx.deallocated).bind { tapGesture in
                if let link = attributes["link"] {
                    try? Router.shared.process(link)
                }
            }
            view.addGestureRecognizer(tap)
        }
        
        self["ui-border-width"] = { view, attribtues in
            guard let width = attribtues["ui-border-width"] else { return }
            guard let fWidth = Float(width) else { return }
            view.layer.borderWidth = CGFloat(fWidth)
        }
    }
}

