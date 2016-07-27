//
//  ViewController.swift
//  weatherForecastFree
//
//  Created by Shahrukh on 7/22/16.
//  Copyright © 2016 DeviseApps. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,CLLocationManagerDelegate,UINavigationBarDelegate,UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {

    @IBOutlet var refreshLocation: UIButton!
    var locationManager = CLLocationManager()
    var countryCode = String()
    var cityWithCountryString = String()
    var weatherList = NSArray()
    let cellReuseIdentifier = "Cell"
    
    @IBOutlet weak var mainWeatherIcon: UIImageView!
    @IBOutlet var weatherTableView: UITableView!
    @IBOutlet var weatherDetailLabel: UILabel!
    @IBOutlet var currentTempLabel: UILabel!
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet var lastupdateWeatherLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        cityNameTextField.delegate = self
        self.currentTempLabel.text = ""
        self.lastupdateWeatherLabel.text = ""
        self.cityName.text = ""
        self.weatherDetailLabel.text = ""
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.cityNameTextField.text = ""
    }
    

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print("location :: \(locations)")
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                print("reverse geodcode fail: \(error!.localizedDescription)")
                return
            }
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print("*********\(placeMark.addressDictionary)\n")
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print("Location Name::\(locationName)")
            }
            
            if let countryCode = placeMark.addressDictionary!["CountryCode"] as? NSString! {
                self.countryCode=countryCode as String
                print("CountryCode Name::\(countryCode)")
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print("street Name::\(street)")
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString!  {
                print("City Name::\(city) and country code::\(self.countryCode)")
                let appendString = NSString(format:"%@,%@",city,self.countryCode)
                self.cityWithCountryString = appendString as String
                
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print("Country Name:: \(country)")
            }
            self.currentWeatherForecast()
            self.loadWeatherDataforCurrentCity()

        })
        locationManager.stopUpdatingLocation()        
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func loadWeatherDataforCurrentCity() {
   
        let modifiedURLString = NSString(format:"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=14&APPID=68b9176690783c9ce5057c118eb44970&units=metric", self.cityWithCountryString) as String
        let url: NSURL = NSURL(string: modifiedURLString)!
        
        print("URL for fetch weather report :: \(url)")
        
        let request = NSMutableURLRequest(URL: url,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    print(json["cnt"] as! Int)
                
                    self.weatherList = json["list"] as! NSArray
                    self.weatherTableView.reloadData()
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        })
        
        dataTask.resume()

    }
    
    func currentWeatherForecast() {
    
        let modifiedURLString = NSString(format:"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=68b9176690783c9ce5057c118eb44970&units=metric", self.cityWithCountryString) as String
        let url: NSURL = NSURL(string: modifiedURLString)!
        
        print("URL for fetch weather report :: \(url)")
        
        let request = NSMutableURLRequest(URL: url,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
            
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    let currentWeatherList = json["main"] as! NSDictionary
                    let currentWeatherTemp = currentWeatherList["temp"] as! Int
                    
                    let weatherDetailsArray = json["weather"] as! NSArray
                    let weatherDetailsTemp:NSDictionary = weatherDetailsArray.objectAtIndex(0) as! NSDictionary
//                    print("weatherDetailsTemp::", weatherDetailsTemp.valueForKey("main") as! String)
                    let date = NSDate(timeIntervalSince1970: json["dt"] as! Double)
                    let dayTimePeriodFormatter = NSDateFormatter()
                    dayTimePeriodFormatter.dateFormat = "hh:mm a"
                    dayTimePeriodFormatter.timeZone = NSTimeZone.localTimeZone()
                    let dateString = dayTimePeriodFormatter.stringFromDate(date)
                    
                    
                    let iconDetails = weatherDetailsTemp.valueForKey("icon") as? String
                    let imgURL = NSURL(string:String(format: "http://openweathermap.org/img/w/%@.png", iconDetails!))
                    let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                        let error = error
                        let data = data
                        if error == nil {
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue(), {
                               self.mainWeatherIcon.image = image
                            })
                        }
                    })
                    task.resume()

                    
                    dispatch_async(dispatch_get_main_queue()) {
                    self.currentTempLabel.text = String(format: "%02d%@", currentWeatherTemp,"\u{00B0}")
                    self.lastupdateWeatherLabel.text = String(format: "Last update: %@",dateString)
                    self.cityName.text = json["name"] as? String
                    self.weatherDetailLabel.text = weatherDetailsTemp.valueForKey("main") as? String
                    self.weatherTableView.reloadData()
                    }

                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        })
        
        dataTask.resume()
    }
    
    @IBAction func reloadLocation(sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
//    MARK:  tabe view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = weatherTableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! customCell
        cell.backgroundColor = UIColor.clearColor()
        let row = indexPath.row
        let weatherListTemp:NSDictionary = self.weatherList[row] as! NSDictionary
        let temp:NSDictionary = weatherListTemp["temp"] as! NSDictionary
        let currentTempCel = temp["day"] as! Int
        let maxTempCel = temp["max"] as! Int
        let minTempCel = temp["min"] as! Int
        let weatherConditionTemp:NSArray = weatherListTemp["weather"] as! NSArray
        let weatherCondition =  (weatherConditionTemp.objectAtIndex(0) as! NSDictionary)
        let weatherConditionMain = weatherCondition["main"] as! NSString
        let weatherConditionDescription = weatherCondition["description"] as! NSString
        cell.currentTemp.text = String(format: "%02d%@", currentTempCel,"\u{00B0}")
        cell.maxTemp.text = String(format: "Max Temp: %02d%@", maxTempCel,"\u{00B0}")
        cell.minTemp.text = String(format: "Min Temp: %02d%@", minTempCel,"\u{00B0}")
        cell.weatherCondition.text = String(format: "%@", weatherConditionMain)
        cell.weatherSubClass.text = String(format: " %@",weatherConditionDescription)
        cell.humidityLabel.text =  String(format:"Humidity: %02d",weatherListTemp["humidity"] as! Int)
        
        let date = NSDate(timeIntervalSince1970: weatherListTemp["dt"] as! Double)
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd"
        dayTimePeriodFormatter.timeZone = NSTimeZone.localTimeZone()
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        cell.dateLabel.text = dateString
        
        let iconDetails = weatherCondition["icon"] as! NSString
        let imgURL = NSURL(string:String(format: "http://openweathermap.org/img/w/%@.png", iconDetails))
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let error = error
            let data = data
            if error == nil {
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), {
                        cell.tempLogo.image = image
                })
            }
        })
        task.resume()


        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.weatherTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
        self.cityNameTextField.autocapitalizationType = .Words
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called:: \(textField)")
        if(!(textField.text?.isEmpty)!){
        self.cityWithCountryString = textField.text!
        self.cityWithCountryString = cityWithCountryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        print("cityWithCountryString:: ",cityWithCountryString)
        self.loadWeatherDataforCurrentCity()
        self.currentWeatherForecast()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        viewWillAppear(true)
        return true;
    }
}

