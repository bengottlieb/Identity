//
//  ViewController.swift
//  IdentityTesting
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import UIKit
import Identity

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func loginWithFacebook() {
		Identity.Facebook.instance.login(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			
		}
	}

	@IBAction func loginWithTwitter() {
		Identity.Twitter.instance.login(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			
		}
	}
}

