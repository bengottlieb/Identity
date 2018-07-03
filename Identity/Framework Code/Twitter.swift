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
	
	var userID: String?
	var isSetup = false

	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		if !self.setup(failable: true) { return false }
		return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
	}
	
	override public func fetchFriends(completion: @escaping FetchFriendsCompletion) {
		self.setup(failable: false)
		
		self.fetchFriends(startingAt: nil, completion: completion)
	}
	
	func fetchFriends(startingAt cursor: Int?, found: [FriendInformation] = [], completion: @escaping FetchFriendsCompletion) {
		let client = TWTRAPIClient(userID: self.userID)
		var error: NSError?
		var params = ["count": "5"]
		if let cursor = cursor { params["cursor"] = "\(cursor)" }
		let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/friends/list.json", parameters: params, error: &error)
		
		client.sendTwitterRequest(request) { response, data, error in
			if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
				let users = json?["users"] as? [[String: Any]] ?? []
				let results = found + users.compactMap { FriendInformation(twitterInfo: $0) }
				
				if let cursor = json?["next_cursor"] as? Int, cursor != 0 {
					self.fetchFriends(startingAt: cursor, found: results, completion: completion)
				} else {
					completion(results, nil)
				}
			}
		}

	}

	
	override public func login(from: UIViewController?, completion: @escaping LoginCompletion) {
		assert(Service.providers.contains(.google), "You're trying to access Twitter without setting it as a provider. Call 'Service.setup(with: [.twitter]).")
		self.setup(failable: false)
		TWTRTwitter.sharedInstance().logIn(with: from) { session, error in
			if let err = error as NSError?, err.domain == "TWTRNetworkingErrorDomain" {
				print("************************\nPlease make sure you have the proper URL schemes configured in your plist, and that you have the right callback URL set on Twitter's app configuration page (https://apps.twitter.com). It should be the same one from your plist, ”twitterkit-\(self.consumerKey)://“.")
			}
			
			self.userID = session?.userID
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
		assert(Bundle.main.cfBundleURLs.filter({ "twitterkit-\(self.consumerKey)" == $0 }).count > 0, "No Twitter CFBundleURL found in the main info.plist")
		TWTRTwitter.sharedInstance().start(withConsumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
		self.isSetup = true
		return true
	}
}
