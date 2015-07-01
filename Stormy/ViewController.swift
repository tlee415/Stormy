//
//  ViewController.swift
//  Stormy
//
//  Created by Terry Lee on 2/25/15.
//  Copyright (c) 2015 Terry Lee. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private let apiKey = "15e26b66c3f4ec0c90b1517e0440391f"
    
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshActivityIndicator.hidden = true;
        getCurrentLocation()
        getCurrentWeatherData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentLocation() -> Void {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    func getCurrentWeatherData() -> Void {

        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)
        
        // sync call
        //let weatherData = NSData(contentsOfURL: forecastURL!, options: nil, error: nil)
        
        // async call
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL( forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                
                let dataObject = NSData(contentsOfURL: location)!
                
                let weatherDictionary = NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as! NSDictionary
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is:"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    // stop refresh animation
                    self.showRefreshButton()
                })
            }
            else {
                
                // alert for error
                self.handleNetworkError()
            }
            
        })
        
        downloadTask.resume()
        
    }
    
    func handleNetworkError() -> Void {

        let networkIssueController  = UIAlertController(title: "Error", message: "Unable to load data.", preferredStyle: .Alert)
        
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        networkIssueController.addAction(okButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        networkIssueController.addAction(cancelButton)
        
        presentViewController(networkIssueController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.showRefreshButton()
        })
        
    }

    func showRefreshButton() -> Void {
        self.refreshActivityIndicator.stopAnimating()
        self.refreshActivityIndicator.hidden = true
        self.refreshButton.hidden = false
    }
    
    func showrefreshActivityIndicator() -> Void {
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
    }
    
    
    @IBAction func refresh() {
        showrefreshActivityIndicator()
        getCurrentWeatherData()
    }


}

