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
		return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
	}
	
	public override func login(from: UIViewController, completion: @escaping LoginCompletion) {
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
						
						completion(UserInformation(provider: .facebook, userID: userID, userName: name, imageURL: imageURL), nil)
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
