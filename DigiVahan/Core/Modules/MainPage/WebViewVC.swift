//
//  WebViewVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import WebKit

/// WebView Screen
///
/// Used to display:
/// - Privacy Policy
/// - Terms & Conditions
/// - About Us
/// - Pay Challan
///
/// Data received:
/// ```swift
/// NavigationManager.pushScreen(
///     from: self,
///     storyboardName: "Main",
///     viewControllerID: "WebViewVC",
///     data: [
///         "policyType": "privacy_policy"
///     ]
/// )
/// ```
class WebViewVC: BaseViewController {
    
    // MARK: - Outlets
    
    /// Progress bar shown while page is loading
    @IBOutlet weak var progressView: UIProgressView!
    
    /// Main webview
    @IBOutlet weak var webView: WKWebView!
    
    /// Initial configuration of WebView
    private var progressObservation: NSKeyValueObservation?
    
    // MARK: - Variables
    
    /// Type of page to load
    ///
    /// Possible Values:
    /// - privacy_policy
    /// - terms_condition
    /// - about_page
    /// - pay_challan
    private var policyType = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupWebView()
        
        // Receive Data
        if let data = receivedData as? [String: Any] {
            
            policyType =
            data["policyType"] as? String ?? ""
        }
        
        fetchPolicyAndLoad()
    }
    
    // MARK: - WebView Setup
    private func setupWebView() {
        
        progressView.progress = 0
        progressView.isHidden = true
        
        webView.navigationDelegate = self
        
        progressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] webView, _ in
            
            guard let self = self else { return }
            
            self.progressView.isHidden = false
            
            self.progressView.progress =
            Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.3
                ) {
                    self.progressView.isHidden = true
                }
            }
        }
    }
    
    
    // MARK: - Load Page
    
    /// Decides which page to open
    /// based on policyType.
    private func fetchPolicyAndLoad() {
        
        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_APP_INFO,
            method: "GET"
        ) { response, status, message in
            
            print("STATUS:", status)
            print("MESSAGE:", message)
            
            guard status else {
                self.showToast(message: "Unable to load policy")
                return
            }
            
            guard let data = response?["data"] as? [String: Any] else {
                self.showToast(message: "Invalid response")
                return
            }
            
            var urlString = ""
            
            switch self.policyType {
                
            case "privacy_policy":
                
                self.title = "Privacy Policy"
                
                if let policy = data["policy"] as? [String: Any],
                   let privacyPolicy = policy["privacy_policy"] as? [String: Any] {
                    
                    urlString =
                    privacyPolicy["policy_page_url"] as? String ?? ""
                }
                
            case "terms_condition":
                
                self.title = "Terms & Conditions"
                
                if let policy = data["policy"] as? [String: Any],
                   let termsCondition = policy["terms_condition"] as? [String: Any] {
                    
                    urlString =
                    termsCondition["terms_condition_page_url"] as? String ?? ""
                }
                
            case "about_page":
                
                self.title = "About Us"
                
                if let policy = data["policy"] as? [String: Any],
                   let aboutPage = policy["About_page"] as? [String: Any] {
                    
                    urlString =
                    aboutPage["about_page_url"] as? String ?? ""
                }
                
            case "pay_challan":
                
                self.title = "Pay Challan"
                
                urlString =
                data["challanPay"] as? String ?? ""
                
            default:
                
                print("Invalid policy type")
                return
            }
            
            guard !urlString.isEmpty else {
                
                self.showToast(message: "URL not found")
                return
            }
            
            guard let url = URL(string: urlString) else {
                
                self.showToast(message: "Invalid URL")
                return
            }
            
            let request = URLRequest(url: url)
            
            self.webView.load(request)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewVC: WKNavigationDelegate {

    /// Page Started Loading
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {

        progressView.isHidden = false
    }

    /// Page Finished Loading
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {

        progressView.isHidden = true
    }

    /// Page Failed
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {

        progressView.isHidden = true

        print(
            "WebView Error:",
            error.localizedDescription
        )
    }
}
