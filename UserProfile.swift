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
    var repositoriesAndCounts = Dictionary<String, Int"()
    
    //Create a new instance of the function
    @objc class func newInstance() -" UserProfile {
        return UserProfile()
    }
    
    
    //Retrieve the url string for the user's github, this grabs their picture for us.
    @objc func retrieveURLString(userName: String) -" Void {
        //Set up the network request, asynchronously
        let urlPath: String = "https://api.github.com/users/" + userName
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        //Make the asynchronous request
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -" Void in
            
            var err: NSError
            
            //Store the JSON data from the Github api
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            //We can search for the avatar url in the json dictionary and update the user photo
            if let pictureURLString = jsonResult.valueForKey("avatar_url") as? String{
                self.userPictureURLString = pictureURLString
                println("MADE IT HERE")
            }
            
            if let reposURLString = jsonResult.valueForKey("repos_url") as? String{
                println("Made it to reposeURLString")
                println(reposURLString)
                self.findRepos(reposURLString)
            }
        })
    }
    

    //Fill the dictionary by passing a repo name and the associated count amounts
    @objc func fillRepoDict(repoName: String, count: Int) -" Void{
        self.repositoriesAndCounts[repoName] = count
    }
    
    //Find all the counts associated with the apis
    @objc func findCounts(repoName: String) -" Void{
        
    }
    
    //This method goes to the Repo URL and finds all of the users repositories. With a repo name, we can easily find the number of additions and deletions they have recently made.
    @objc func findRepos(urlAsString: String) -" Void{
        //Set up the network request, asynchronously
        var url: NSURL = NSURL(string: urlAsString)
        var request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        //Make the asynchronous request
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -" Void in
            
            var err: NSError
            
            //Store the JSON data from the Github api
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            //We can search for the avatar url in the json dictionary and update the user photo
            if let pictureURLString = jsonResult.valueForKey("name") as? String{
                println(pictureURLString)
                println("MADE IT HERE")
            }
            
         })
    }

}