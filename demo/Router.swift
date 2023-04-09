//
//  Router.swift
//  demo
//
//  Created by shayanbo on 2023/4/9.
//

import UIKit

extension Router {
    
    enum Error: Swift.Error {
        case noNavigator
        case noWebDefaultRouter
    }
}

/// **lite** router
class Router {
    
    typealias Handler = ([String:String]) -> Void
    
    static var shared: Router = Router()
    
    private var controllers = [String: UIViewController.Type]()
    private var handlers = [String: Handler]()
    
    private(set) var navigator: UINavigationController?
    
    func registerRootNavigator(_ navigator: UINavigationController) {
        self.navigator = navigator
    }
    
    func process(_ path: String) throws {
        
        guard let (path, params) = parse(from: path) else {
            return
        }
        
        if let handler = handlers[path] {
            
            /// call handler with params
            handler(params)
            
        } else if let controllerType = controllers[path] {
            
            guard let navigator = self.navigator else {
                throw Error.noNavigator
            }
            
            let oType = controllerType as NSObject.Type
            let object = oType.init()
            if object.responds(to: NSSelectorFromString("setParams:")) {
                object.perform(NSSelectorFromString("setParams:"), with: params)
            }
            
            /// create view controller and navigate to it
            let controller = object as! UIViewController
            navigator.pushViewController(controller, animated: true)
            
        } else if path.hasPrefix("http") {
            
            /// we define /web_browser as the default route
            let handler: Handler? = self["/web_browser"]
            guard let _ = handler else {
                throw Error.noWebDefaultRouter
            }
            try? process("/web_browser?url=\(path)")
        }
    }
    
    subscript(_ path: String) -> UIViewController.Type? {
        get { controllers[path] }
        set { controllers[path] = newValue }
    }
    
    subscript(_ path: String) -> Handler? {
        get { handlers[path] }
        set { handlers[path] = newValue }
    }
}

extension Router {
    func parse(from path: String) -> (String, [String: String])? {
        
        guard var urlComponents = URLComponents(string: path) else { return nil }
        
        var par = [String: String]()
        urlComponents.queryItems?.forEach({ queryItem in
            par[queryItem.name] = queryItem.value
        })
        
        urlComponents.query = nil
        guard let path = urlComponents.string else { return nil }
        
        return (path, par)
    }
}
