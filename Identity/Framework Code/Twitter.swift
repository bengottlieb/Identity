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
	public var consumerKey: String!
	public var consumerSecret: String!
	
	
	var isSetup = false
	func setup() {
		if self.isSetup { return }
		TWTRTwitter.sharedInstance().start(withConsumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
		self.isSetup = true
	}
	
	public func login(from: UIViewController) {
		self.setup()
		TWTRTwitter.sharedInstance().logIn(with: from) { session, error in
			
		}
	}
}
