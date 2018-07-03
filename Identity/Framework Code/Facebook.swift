//
//  Facebook.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public class Facebook: Service {
	public static let instance = Facebook()
	
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		assert(Bundle.main.cfBundleURLs.filter({ $0.hasPrefix("fb")}).count > 0, "No Facebook CFBundleURL found in the main info.plist")
		return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
	}
	
	var friends: [[String: Any]]?
	
	public override func fetchFriends(completion: @escaping FetchFriendsCompletion) {
		completion(self.friends?.compactMap { FriendInformation(facebookInfo: $0) }, nil)
	}
	
	public override func login(from: UIViewController?, completion: @escaping LoginCompletion) {
		assert(Service.providers.contains(.facebook), "You're trying to access Facebook without setting it as a provider. Call 'Service.setup(with: [.facebook]).")
		let perms = ["user_friends", "email", "public_profile"]
		let loginManager = FBSDKLoginManager()
		
		loginManager.logIn(withReadPermissions: perms, from: from) { result, error in
			if result != nil {
				let infoRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, friends"], httpMethod: "GET")
				_ = infoRequest?.start() { connection, result, error in
					if let json = result as? [String: Any] {
						let name = json["name"] as? String ?? ""
						let userID = json["id"] as? String ?? ""
						let imageURL = "https://graph.facebook.com/\(userID)/pciture?type=large"
						
						if let friends = json["friends"] as? [String: Any] {
							self.friends = friends["data"] as? [[String: Any]] ?? []
						}
						
						self.userInformation = UserInformation(provider: .facebook, userID: userID, userName: name, imageURL: imageURL)
						completion(self.userInformation, nil)
					} else {
						completion(nil, error)
					}
				}
			} else {
				completion(nil, error)
			}
		}

	}

}
