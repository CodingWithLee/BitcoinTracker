//
//  ViewController.swift
//  BitcoinTracker
//
//  Created by Lee Gray on 15/03/2019.
//  Copyright © 2019 Lee Gray. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Firebase

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    var interstitial: GADInterstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/2934735716")
    
    //sample ca-app-pub-3940256099942544/4411468910
    //actual ca-app-pub-3815063168714899/3401708403
    
    var bannerView: GADBannerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(currencyArray[row])
        finalURL = baseURL + currencyArray[row]
        currencySelected = currencySymbolArray[row]
        print(finalURL)
        getBitcoinData(url: finalURL)
    }
    
    @IBAction func predictButton(_ sender: UIButton) {
        let number = Int.random(in: 0 ..< 2)
        
        
        if number == 0 {
            predictLabel.text = "Bitcoin to go UP"
        }
         else {
            predictLabel.text = "Bitcoin to go DOWN"
        }
        
    }
    
    @IBOutlet weak var predictLabel: UILabel!
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var finalURL = ""
    var currencySelected = ""
    
    let currencySymbolArray = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    
    //Pre-setup IBOutlets


    @IBOutlet weak var bitcoinPriceLaabel: UILabel!
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        bannerView.delegate = self
        
        //addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3815063168714899/6793146745"
        
        //actual ca-app-pub-3815063168714899/6793146745
        //sample ca-app-pub-3940256099942544/2934735716
        
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
        
        //addBannerViewToView(bannerView)
        
        
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)

        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
        createAndLoadInterstitial()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtTopOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtTopOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtTopOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.topAnchor.constraint(equalTo: bannerView.topAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtTopOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide.topAnchor ,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerView.isHidden = true
    }
    
    
    func playAd()
    {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            
        } else {
            print("Ad wasn't ready")
        }
        
    }
    
    fileprivate func createAndLoadInterstitial(){
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3815063168714899/3401708403")
        
        //sample ca-app-pub-3940256099942544/4411468910
        //actual ca-app-pub-3815063168714899/3401708403
        
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
    }
    
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    }

    
    func getBitcoinData(url: String) {
        playAd()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    //print("Sucess! Got the bitcoin data")
                    let bitcoinJSON : JSON = JSON(response.result.value!)
                    
                    self.updateBitcoinData(json: bitcoinJSON)
                    
                } else {
                    //print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLaabel.text = "Connection Issues"
                }
        }
        
    }
    

    func updateBitcoinData(json : JSON) {
        
        if let bitcoinResult = json["ask"].double {
            
            bitcoinPriceLaabel.text = "\(currencySelected)\(bitcoinResult)"
        } else {
            bitcoinPriceLaabel.text = "Price Unavailable"
        }
    }
    
}
