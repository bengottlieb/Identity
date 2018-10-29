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
import Bolts

public class Facebook: Service {
	public static let instance = Facebook()
	var completions: [LoginCompletion] = []
	override var provider: Provider { return .facebook }
	public var applicationID: String? { return Bundle.main.infoDictionary?["FacebookAppID"] as? String }
	
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		if FBSDKAccessToken.current() != nil {
			self.requestUserInfo(completion: { _,_  in })
		}
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		assert(Bundle.main.cfBundleURLs.filter({ $0.hasPrefix("fb")}).count > 0, "No Facebook CFBundleURL found in the main info.plist")
		return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
	}
	
	var friends: [[String: Any]]?
	let perms = ["user_friends", "email", "public_profile"]

	public override func fetchFriends(completion: @escaping FetchFriendsCompletion) {
		completion(self.friends?.compactMap { FriendInformation(facebookInfo: $0) }, nil)
	}
	
	override public var isAvailable: Bool { return Service.providers.contains(.facebook) && Bundle.main.cfBundleURLs.filter({ $0.hasPrefix("fb")}).count > 0 && self.applicationID != nil }

	public override func signIn(from: UIViewController?, completion: @escaping LoginCompletion) {
		assert(Service.providers.contains(.facebook), "You're trying to access Facebook without setting it as a provider. Call 'Service.setup(with: [.facebook]).")
		let loginManager = FBSDKLoginManager()
		
		if self.completions.count > 0 {
			self.completions.append({ id, error in
				if id == nil {
					self.signIn(from: from, completion: completion)
				} else {
					completion(id, error)
				}
			})
			return
		}

		
		loginManager.logIn(withReadPermissions: self.perms, from: from) { result, error in
			if result != nil {
				self.requestUserInfo(completion: completion)
			} else {
				completion(nil, error)
			}
		}
	}
	
	func requestUserInfo(completion: @escaping LoginCompletion) {
		if self.completions.count > 0 {
			self.completions.append(completion)
			return
		}
		
		self.completions = [completion]
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
				self.callCompletions(with: nil)
				completion(self.userInformation, nil)
			} else {
				self.callCompletions(with: error)
			}
		}
	}
	
	func callCompletions(with error: Error?) {
		let completions = self.completions
		self.completions = []
		
		completions.forEach { $0(self.userInformation, error) }
		
	}

}
