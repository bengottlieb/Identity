//
//  Twitter.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import TwitterKit

public class Twitter {
	public static let instance = Twitter()
	public var consumerKey: String = ""
	public var consumerSecret: String = ""
	
	
	var isSetup = false
	func setup() {
		if self.isSetup { return }
		if self.consumerKey.isEmpty || self.consumerSecret.isEmpty {
			print("************************\nPlease set your Consumer Key and Consumer Secret values before signing in with Twitter.")
			fatalError()
		}
		TWTRTwitter.sharedInstance().start(withConsumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
		self.isSetup = true
	}
	
	public func login(from: UIViewController) {
		self.setup()
		TWTRTwitter.sharedInstance().logIn(with: from) { session, error in
			if let err = error as NSError?, err.domain == "TWTRNetworkingErrorDomain" {
				print("************************\nPlease make sure you have the proper URL schemes configured in your plist, and that you have the right callback URL set on Twitter's app configuration page (https://apps.twitter.com). It should be the same one from your plist, ”twitterkit-\(self.consumerKey)“.")
			}
		}
	}
}
