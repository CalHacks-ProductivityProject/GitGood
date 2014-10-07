//
//  UserProfile.swift
//  CalHacksProject
//
//  Created by Peter Kaminski on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

import Foundation

//This class creates a UserProfile based on the user's Github information
@objc class UserProfile{
    //A profile needs a username and a picture, we need to find the url for the picture based on the given username
    var userName: String = "Default User"
    //Default OctoCat picture until we find the user's picture
    var userPictureURLString: String = "https://lh5.googleusercontent.com/-tw5LsU4Fg28/Umo6BBcoCnI/AAAAAAAAmjE/1iqULsem06E/s1140-no/heisencat.png"
    //Dictionary that stores the user's repos and their addtions and deletions
    var repositoriesAndCounts = Dictionary<String, Int>()
    
    
    //Create a new instance of the function
    @objc class func newInstance() -> UserProfile {
        return UserProfile()
    }
    
    
    //Retrieve the url string for the user's github, this grabs their picture for us.
    @objc func retrieveURLString(userName: String) -> Void {
        //Set the user's name
        self.userName = userName
        //Set up the network request, asynchronously
        //UrlPath is the GitHub RestAPI URL + the user's name
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
            }
            
            //We can also find the user's repositories
            if let reposURLString = jsonResult.valueForKey("repos_url") as? String{
                //Pass the repos_url from the user's github information to find their repos
                self.findUserRepositories(reposURLString)
            }
        })
        
    }
    
    //findUserRepositories takes a URL and establishes the repositories and counts Dictionary
    @objc func findUserRepositories(urlString: String){
        
        //Standard Networking on Swift
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
        
        //create an array and store all the repositories that the user has
        else if let nsArrayObject = swiftObject as? NSArray {
            //For each element in the array, find the name path, and store it
            for element in nsArrayObject{
                var name: AnyObject! = element.valueForKeyPath("name")
                //If the name is not nil, then we can find the repo and store that information into the reposAndCounts dictionary
                if let validRepo: AnyObject = name{
                    findRepo(validRepo)
                }
            }
        }
    }
    
    
    @objc func findRepo(repoName: AnyObject) -> Void {
        println(repoName)
        //Standard Networking on Swift
        //url is the github rest plus the username plus the repoName + the stats/code_frequency
        var url: NSURL = NSURL(string: "https://api.github.com/repos/" + self.userName +  "/" + String(repoName as NSString) + "/stats/code_frequency")
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
                println("Dictionary")
            }
        }
            //create an array and store all the repositories that the user has
        else if let nsArrayObject = swiftObject as? NSArray {
            //Find out the last element in the list, that is this most current week.
            
            if let lastElement = nsArrayObject[nsArrayObject.count - 1] as? NSNumber {
                println("Array")
                
            }
            
            for element in nsArrayObject {
                println(element)
            }
            
        }
        
        
        
    }
    
}