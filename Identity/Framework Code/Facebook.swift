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

public class Facebook {
	public static let instance = Facebook()
	
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		
		return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
	}
	
	public func login(from: UIViewController) {
		let perms = ["user_friends", "email", "public_profile"]
		let loginManager = FBSDKLoginManager()
		
		loginManager.logIn(withReadPermissions: perms, from: from) { result, error in
		}

	}

}
