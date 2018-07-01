//
//  Twitter.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import TwitterKit

public class Twitter: Service {
	public static let instance = Twitter()
	public var consumerKey: String = ""
	public var consumerSecret: String = ""
	
	var isSetup = false

	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		if !self.setup(failable: true) { return false }
		return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
	}
	
	override public func login(from: UIViewController, completion: @escaping LoginCompletion) {
		self.setup(failable: false)
		TWTRTwitter.sharedInstance().logIn(with: from) { session, error in
			if let err = error as NSError?, err.domain == "TWTRNetworkingErrorDomain" {
				print("************************\nPlease make sure you have the proper URL schemes configured in your plist, and that you have the right callback URL set on Twitter's app configuration page (https://apps.twitter.com). It should be the same one from your plist, ”twitterkit-\(self.consumerKey)://“.")
			}
			
			if let session = session {
				completion(UserInformation(provider: .twitter, userID: session.userID, userName: session.userName), nil)
			} else {
				completion(nil, error)
			}
			
		}
	}
}

extension Twitter {
	@discardableResult func setup(failable: Bool = true) -> Bool {
		if self.isSetup { return true }
		if self.consumerKey.isEmpty || self.consumerSecret.isEmpty {
			print("************************\nPlease set your Consumer Key and Consumer Secret values before signing in with Twitter.")
			if !failable { fatalError() }
			return false
		}
		TWTRTwitter.sharedInstance().start(withConsumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
		self.isSetup = true
		return true
	}
}
