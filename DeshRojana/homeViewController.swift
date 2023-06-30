//
//  ViewController.swift
//  tab
//
//  Created by awnish on 27/06/23.
//

import UIKit
import WebKit
import SystemConfiguration
import SafariServices


class homeViewController: UIViewController {
    
    
    
    
    
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

        guard let url = URL(string: "https://deshrojana.com") else {
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

func isInternetAvailable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return (isReachable && !needsConnection)
}

func displayNoInternetAlert(in viewController: UIViewController) {
    let alert = UIAlertController(title: "No Internet Connection", message: "Your internet connection is not available.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
        // Show a message or navigate to an informative view
        showNoInternetMessage(in: viewController)
    }))

    viewController.present(alert, animated: true, completion: nil)
}

func showNoInternetMessage(in viewController: UIViewController) {
    let messageLabel = UILabel()
    messageLabel.textAlignment = .center
    messageLabel.text = "No Internet Connection! Please Connect with Internet..."
    messageLabel.textColor = .black
    messageLabel.font = UIFont.systemFont(ofSize: 24)
    messageLabel.sizeToFit()

    messageLabel.center = viewController.view.center
    viewController.view.addSubview(messageLabel)
}


