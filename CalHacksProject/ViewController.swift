//
//  ViewController.swift
//  CalHacksProject
//
//  Created by Peter Kaminski on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var profile = UserProfile(userName: "PeterKaminski09")
        NSLog("%@", profile.userPictureURLString)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

