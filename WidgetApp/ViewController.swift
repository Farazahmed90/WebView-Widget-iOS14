//
//  ViewController.swift
//  WidgetApp
//
//  Created by Faraz_Ahmed on 02/10/2020.
//

import UIKit
import WebKit
import Photos
import AssetsLibrary
import WidgetKit

class ViewController: UIViewController {
    
    static var imageOfWeb: UIImage?
    var url: URL?
    var imageData: Data?
    static var lastImage: UIImage?
    var urlTextField = "https://ios-widgets.vercel.app/"
    
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
        let urlString:String = "https://ios-widgets.vercel.app/"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.loadLastImageThumb { (image) in
            ViewController.lastImage = image
        }
    }
    
    func showIndicator(show: Bool) {
        if show {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true {
            noInternet.isHidden = true
            print("Internet connection OK")
            let urlString:String = "https://ios-widgets.vercel.app/"
            let url:URL = URL(string: urlString)!
            let urlRequest:URLRequest = URLRequest(url: url)
            webV.load(urlRequest)
            self.webV.addSubview(self.indicator)
            self.indicator.style = .whiteLarge
            self.indicator.color = .blue
            self.indicator.startAnimating()
            self.webV.navigationDelegate = self
            self.indicator.hidesWhenStopped = true
            
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
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            UserDefaults().set(self.imageData, forKey: "image")
            ViewController.loadLastImageThumb { (image) in
                ViewController.lastImage = image
            }
            return false
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    func fetchLatestPhotos(forCount count: Int?) -> PHFetchResult<PHAsset> {
        // Create fetch options.
        let options = PHFetchOptions()
        
        // If count limit is specified.
        if let count = count { options.fetchLimit = count }
        
        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options)
        
    }
    static func loadLastImageThumb(completion: @escaping (UIImage) -> ()) {
        let imgManager = PHImageManager.default()
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if let last = fetchResult.lastObject {
            let scale = UIScreen.main.scale
            let size = CGSize(width: 100 * scale, height: 100 * scale)
            let options = PHImageRequestOptions()
            
            
            imgManager.requestImage(for: last, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image, _) in
                if let image = image {
                    completion(image)
                }
            })
        }
        
    }
}
extension ViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showIndicator(show: false)
        urlTextField = (webView.url?.absoluteString)!
        webView.sizeToFit()
        UIGraphicsBeginImageContext(webView.frame.size)
        webView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let previewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ViewController.imageOfWeb = previewImage
        let croppedRect = CGRect(x: 0, y: 0, width: 300, height: 280)
        UserDefaults.group.setImage(image: previewImage?.cropBottom(to: croppedRect), forKey: "photo")
        WidgetCenter.shared.reloadAllTimelines()
        let yourDataImagePNG = previewImage!.pngData()
        self.imageData = yourDataImagePNG
        self.isAppAlreadyLaunchedOnce()
        saveImage(image: previewImage!)
        previewImage?.saveToPhotoLibrary(completion: { (url) in
            print(url)
        })
    }
}
