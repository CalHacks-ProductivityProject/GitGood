//
//  UserProfile.swift
//  CalHacksProject
//
//  Created by Peter Kaminski on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

import Foundation

@objc class UserProfile{
    //A profile needs a username and a picture, we need to find the url for the picture based on the given username
    var userName: String = "Default User"
    var userPictureURLString: String = "https://lh5.googleusercontent.com/-tw5LsU4Fg28/Umo6BBcoCnI/AAAAAAAAmjE/1iqULsem06E/s1140-no/heisencat.png"
    var repositoriesAndCounts = Dictionary<String, Int>()
    
    //Create a new instance of the function
    @objc class func newInstance() -> UserProfile {
        return UserProfile()
    }
    
    
    //Retrieve the url string for the user's github, this grabs their picture for us.
    @objc func retrieveURLString(userName: String) -> Void {
        //Set up the network request, asynchronously
        let urlPath: String = "https://api.github.com/users/" + userName
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        //Make the asynchronous request
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var err: NSError
            
            //Store the JSON data from the Github api
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            //We can search for the avatar url in the json dictionary and update the user photo
            if let pictureURLString = jsonResult.valueForKey("avatar_url") as? String{
                self.userPictureURLString = pictureURLString
                println("MADE IT HERE")
            }
            
            if let reposURLString = jsonResult.valueForKey("repos_url") as? String{
                self.findUserRepositories(reposURLString)
            }
        })
        
    }
    
    @objc func findUserRepositories(urlString: String){
        println("STRING")
        println(urlString)
        
        var url: NSURL = NSURL(string: urlString)
        var request: NSURLRequest = NSURLRequest(URL: url)
        let queue: NSOperationQueue = NSOperationQueue()
        
            
        //Store the JSON data from the Github api
        var jsonResult: NSData  = NSData(contentsOfURL: url)
        
        var error:NSError?
        
        // Retrieve Data
        var JSONData = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions(), error: &error)
        // Create another error optional
        var jsonerror:NSError?
        // We don't know the type of object we'll receive back so use AnyObject
        let swiftObject:AnyObject = NSJSONSerialization.JSONObjectWithData(JSONData, options: NSJSONReadingOptions.AllowFragments, error:&jsonerror)!
        // JSONObjectWithData returns AnyObject so the first thing to do is to downcast this to a known type
        if let nsDictionaryObject = swiftObject as? NSDictionary {
            if let swiftDictionary = nsDictionaryObject as Dictionary? {
                println(swiftDictionary)
            }
        }
        else if let nsArrayObject = swiftObject as? NSArray {
            if let swiftArray = nsArrayObject as Array? {
                var array: AnyObject = swiftArray[0]
                var name : AnyObject = array.valueForKeyPath("name")
                
                println(name)
            }
        }
        
    }
    
    
}