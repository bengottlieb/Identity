//
//  ViewController.swift
//  IdentityTesting
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import UIKit
import Identity

extension UIButton {
	func setEnabled(_ enabled: Bool) {
		self.alpha = enabled ? 1.0 : 0.1
	}
}

class ViewController: UIViewController {
	@IBOutlet var cloudKitButton: UIButton!
	@IBOutlet var gameCenterButton: UIButton!
	@IBOutlet var googleButton: UIButton!
	@IBOutlet var twitterButton: UIButton!
	@IBOutlet var facebookButton: UIButton!

	var allButtons: [UIButton] { return [self.cloudKitButton, self.googleButton, self.gameCenterButton, self.twitterButton, self.facebookButton ]}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.updateAvailability()
		NotificationCenter.default.addObserver(self, selector: #selector(updateAvailability), name: Service.Notifications.availabilityChanged, object: nil)
	}
	
	@objc func updateAvailability() {
		self.cloudKitButton.setEnabled(CloudKit.instance.isAvailable)
		self.gameCenterButton.setEnabled(GameCenter.instance.isAvailable)
		self.googleButton.setEnabled(Google.instance.isAvailable)
		self.twitterButton.setEnabled(Twitter.instance.isAvailable)
		self.facebookButton.setEnabled(Facebook.instance.isAvailable)
	}
	
	

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func loginWithFacebook() {
		Identity.Facebook.instance.signIn(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			
		}
	}
	
	@IBAction func loginWithGoogle() {
		Identity.Google.instance.signIn(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			
		}
	}

	@IBAction func loginWithCloudKit() {
		Identity.CloudKit.instance.signIn(from: self) { result, error in
			
		}
	}

	@IBAction func loginWithGameCenter() {
		Identity.GameCenter.instance.signIn(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			Identity.GameCenter.instance.fetchFriends(completion: { friends, error in
				print("Friends: \(friends!)")
			})
		}
	}

	@IBAction func loginWithTwitter() {
		Identity.Twitter.instance.signIn(from: self) { result, error in
			if let info = result { print("info: \(info)") }
			Identity.Twitter.instance.fetchFriends(completion: { friends, error in
				
			})
		}
	}
}

