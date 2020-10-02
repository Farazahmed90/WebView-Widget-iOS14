//
//  ViewController.swift
//  WidgetApp
//
//  Created by Faraz_Ahmed on 02/10/2020.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var webV: WKWebView!
    @IBOutlet weak var noInternet: UIView!
    
    @IBAction func homePressed(_ sender: Any) {
        webV.reload()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        homePress()
    }
    
    func homePress() {
       let urlString:String = "https://www.google.com/"
       let url:URL = URL(string: urlString)!
       let urlRequest:URLRequest = URLRequest(url: url)
       webV.load(urlRequest)
       self.webV.addSubview(self.indicator)
       self.indicator.style = .whiteLarge
       self.indicator.color = .blue
       self.indicator.startAnimating()
       self.webV.navigationDelegate = self
       self.indicator.hidesWhenStopped = true
    }
    var urlTextField = "https://www.google.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.isNavigationBarHidden = true
      // self.webV.scrollView.delegate = self
      // add activity
    }
    
    func showIndicator(show: Bool) {
        if show {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view, typically from a nib.
        if Reachability.isConnectedToNetwork() == true {
            noInternet.isHidden = true
            print("Internet connection OK")
            let urlString:String = "https://www.google.com/"
            let url:URL = URL(string: urlString)!
            let urlRequest:URLRequest = URLRequest(url: url)
            webV.load(urlRequest)
            self.webV.addSubview(self.indicator)
            self.indicator.style = .whiteLarge
            self.indicator.color = .blue
            self.indicator.startAnimating()
            self.webV.navigationDelegate = self
            self.indicator.hidesWhenStopped = true
            //Camera
            
            
        } else {
            print("Internet connection FAILED")
            
            let alert = UIAlertController(title: "No internet connection", message: "Make sure that your device is connected to the Internet.", preferredStyle: .alert)
            let okButtonAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButtonAction)
            self.present(alert, animated: true, completion: nil)
            noInternet.isHidden = false
            webV.isHidden = true
            
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showIndicator(show: false)
        urlTextField = (webView.url?.absoluteString)!
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showIndicator(show: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

//extension ViewController: UIScrollViewDelegate {
//   func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//      scrollView.pinchGestureRecognizer?.isEnabled = false
//   }
//}


