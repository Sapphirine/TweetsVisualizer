//
//  ViewController.swift
//  TweetsVisualizer
//
//  Created by Linyin Wu on 5/5/15.
//  Copyright (c) 2015 Linyin Wu. All rights reserved.
//

import UIKit
import TwitterKit
import MapKit
import CoreLocation


var tweets = [Tweet]()
var tweetsDict = Dictionary<String, Tweet>()

var tweetToBeDetailed : Tweet?

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var mapV: MKMapView!
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapV.showsUserLocation = true
        var latitude :CLLocationDegrees = 40.8075
        var longitude :CLLocationDegrees = -73.9619
        var latDelta : CLLocationDegrees = 0.04
        var longDelta : CLLocationDegrees = 0.04
        var span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var userLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region : MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        mapV.setRegion(region, animated: true)
        mapV.delegate = self
        poll()
        var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "poll", userInfo: nil, repeats: true)
        
    }
    
    func poll(){
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            if (session != nil) {
                println("signed in as \(session.userName)")
                let searchEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
                let params = ["q":"","geocode":"40.8075,-73.9619,1.5mi","count":"100"]
                var clientError : NSError?
                
                let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
                    "GET", URL: searchEndpoint, parameters: params,
                    error: &clientError)
                
                if request != nil {
                    Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                        (response, data, connectionError) -> Void in
                        if (connectionError == nil) {
                            var jsonError : NSError?
                            let json : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as NSDictionary
                            if jsonError == nil {
                                if let statuses : NSArray = json["statuses"] as? NSArray {
                                    
                                    for i in 0...(statuses.count-1) {
                                        
                                        if let status = statuses[i] as? NSDictionary {
                                            if let userInfo = status["user"] as? NSDictionary {
                                                let idNum = userInfo["id"] as NSNumber
                                                let tweet = Tweet(id: toString(idNum), name: userInfo["screen_name"] as String, text: status["text"] as String, timestamp: status["created_at"] as String, avatarUrl: userInfo["profile_image_url"] as String)
                                                if let geo = status["geo"] as? NSDictionary{
                                                    let co = geo["coordinates"] as NSArray
                                                    tweet.coordinate = CLLocationCoordinate2DMake(co[0] as Double, co[1] as Double)
                                                    if((tweetsDict.indexForKey("@\(tweet.name)")) != nil) {
                                                        continue;
                                                    }
                                                    tweetsDict["@\(tweet.name)"] = tweet
                                                    tweets.append(tweet)
                                                    
//                                                    println(tweet.id)
                                                    
                                                    var err: NSError?
                                                    
                                                    let newString = tweet.text.stringByReplacingOccurrencesOfString(" ", withString: "+")
//                                                    println(newString)
                                                    var urlStr = "http://www.sentiment140.com/api/classify?text=\(newString)?appid=wulinyin1@gmail.com"
                                                    let url = NSURL(string: urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                                                    println(url)
                                                    let request = NSURLRequest(URL: url!)
                                                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                                                        
                                                        println(NSString(data: data, encoding: NSUTF8StringEncoding))
                                                        println("................aaaa")
                                                        
                                                        if let d = NSString(data: data, encoding: NSUTF8StringEncoding) as NSString?{
                                                            let j : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as NSDictionary
                                                            if err == nil {
                                                                if let results = j["results"] as? NSDictionary {
                                                                    if let p = results["polarity"] as? NSNumber{
                                                                        tweet.polarity = p
                                                                        
                                                                        var annotation = MKPointAnnotation()
                                                                        annotation.coordinate = tweet.coordinate!
//                                                                        annotation
                                                                        annotation.title = "@\(tweet.name)"
                                                                        annotation.subtitle = tweet.text
                                                                        self.mapV.addAnnotation(annotation)
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                }
                                            }
                                        }
                        
                                        if tweets.count == 500 {
                                            for i in 0...9 {
                                                tweetsDict.removeValueForKey(tweets[0].id)
                                                tweets.removeAtIndex(0)
                                            }
                                        }

                                    }
                                    
                                }
                            }else {
                                println("Error: \(jsonError)")
                            }
                            
                        }else {
                            println("Error: \(connectionError)")
                        }
                    }
                }else {
                    println("Error: \(clientError)")
                }
            }else {
                println("error: \(error.localizedDescription)");
            }
        }
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView!.canShowCallout = true
        
        var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        pinView!.rightCalloutAccessoryView = calloutButton
        
        pinView!.animatesDrop = true
        
        
        // 0 : negative, 2 : neutral, 4 : positive
        let key:String = annotation.title!
        let t:Tweet = tweetsDict[key]!
        if t.polarity == 0 {
            pinView.pinColor = .Red
        }else if t.polarity == 2 {
            pinView.pinColor = .Purple
        }else if t.polarity == 4 {
            pinView.pinColor = .Green
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("call out!")
        if let a = view.annotation.title {
            tweetToBeDetailed = tweetsDict[a!]
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("detail", sender: self)
        }
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "detail" {
//            var vc = segue.destinationViewController as tweetViewController
//            
//            println("can work?")
//        }
//    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let regionToZoom = MKCoordinateRegionMake(manager.location.coordinate, MKCoordinateSpanMake(0.04, 0.04))
        mapV.setRegion(regionToZoom, animated: true)
    }
    
}

