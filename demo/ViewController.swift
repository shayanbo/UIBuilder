//
//  ViewController.swift
//  demo
//
//  Created by shayanbo on 2023/3/30.
//

import UIKit
import Combine
import SafariServices

class ViewController: UIViewController, UITextViewDelegate {

    var root: UIView?
    
    var editView: UITextView!
    var displayView: UIView!
    
    let printer = ViewPrinter()
    let colorCode = ColorCode()!
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        /// register http default router
        Router.shared["/web_browser"] = { params in
            guard let urlString = params["url"] else { return }
            guard let url = URL(string: urlString) else { return }
            let safari = SFSafariViewController(url: url)
            Router.shared.navigator?.present(safari, animated: true)
        }
        
        /// left part view setup
        editView = UITextView()
        editView.font = UIFont.systemFont(ofSize: 20)
        editView.textColor = .white
        editView.backgroundColor = .black.withAlphaComponent(0.85)
        self.view.addSubview(editView)
        editView.delegate = self
        
        /// right part view setup
        displayView = UIView()
        self.view.addSubview(displayView)
        
        /// ui assembly
        self.view.yoga.isEnabled = true
        editView.yoga.isEnabled = true
        displayView.yoga.isEnabled = true
        self.view.yoga.flexDirection = .row
        editView.yoga.flexGrow = 1
        displayView.yoga.flexGrow = 1
        
        self.view.yoga.applyLayout(preservingOrigin: true)
        
        /// render initial content
        guard let path = Bundle.main.path(forResource: "sample", ofType: "xml") else { return }
        guard let xml = try? String(contentsOfFile: path) else { return }
        editView.attributedText = colorCode.render(xml)
        textViewDidChange(editView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        /// keep cursor untouched
        let selection = textView.selectedRange
        textView.attributedText = colorCode.render(textView.text)
        textView.selectedRange = selection
        
        /// render in real time
        if let generatedView = self.printer.build(from: textView.text) {
            self.root?.removeFromSuperview()
            self.root = generatedView
            
            self.displayView.addSubview(generatedView)
            generatedView.frame = self.displayView.bounds
            generatedView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            generatedView.yoga.applyLayout(preservingOrigin: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
