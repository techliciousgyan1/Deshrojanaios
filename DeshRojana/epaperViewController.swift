//
//  epaperViewController.swift
//  tab
//
//  Created by awnish on 27/06/23.
//

import UIKit
import WebKit
import SystemConfiguration
import SafariServices


class epaperViewController: UIViewController {

    
    
    
    let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        view.addSubview(webView)
        
        // Add refresh control to the web view
                webView.scrollView.addSubview(refreshControl)
                refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let url = URL(string: "https://deshrojana.com/category/epaper/") else {
            return
        }

        if !isInternetAvailable() {
            displayNoInternetAlert(in: self)
            return
        }

        webView.load(URLRequest(url: url))

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let html = result as? String, error == nil else {
                    return
                }
                print(html)
                
                if html.contains("whatsapp://send") {
                                // Handle WhatsApp URL scheme
                                self.handleWhatsAppShare()
                            }
            }
        }
    }
    
    
    private func handleWhatsAppShare() {
        guard let url = URL(string: "whatsapp://send") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            // Open the WhatsApp app
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // WhatsApp is not installed, display an error or alternative action
            print("WhatsApp is not installed.")
        }
    }

    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Adjust the frame of the web view to exclude safe area insets
            webView.frame = CGRect(x: view.safeAreaInsets.left,
                                   y: view.safeAreaInsets.top,
                                   width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                                   height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        }
    
    
    @objc func refreshWebView() {
          webView.reload()
      }

}


