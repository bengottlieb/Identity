//
//  Google.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import GoogleSignIn

public class Google: Service {
	public static let instance = Google()
	
	public var clientID = ""
	
	var host: UIViewController?
	var completion: LoginCompletion?
	
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		GIDSignIn.sharedInstance().clientID = self.clientID
		GIDSignIn.sharedInstance().delegate = self
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		assert(!self.clientID.isEmpty, "Make sure you set a Google Login client ID before attempting to use it.")
		assert(Bundle.main.cfBundleURLs.filter({ $0.hasPrefix("com.googleusercontent.apps")}).count > 0, "No Google CFBundleURL found in the main info.plist")
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
	}

	public override func login(from: UIViewController, completion: @escaping LoginCompletion) {
		GIDSignIn.sharedInstance().uiDelegate = self
		self.host = from
		self.completion = completion
		
		GIDSignIn.sharedInstance().signIn()
	}
}

extension Google: GIDSignInDelegate {
	public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		if let error = error {
			self.completion?(nil, error)
		} else {
			let userId = user.userID                  // For client-side use only!
			let idToken = user.authentication.idToken // Safe to send to the server
			let email = user.profile.email
			let givenName = user.profile.givenName

			self.completion?(UserInformation(provider: .google, userID: idToken ?? userId ?? "", userName: email ?? givenName ?? ""), nil)
		}
		
		self.completion = nil
	}
	
	public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		
	}
}

extension Google: GIDSignInUIDelegate {
	public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		
	}
	
	public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		self.host?.dismiss(animated: true, completion: nil)
	}
	
	
	public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		self.host?.present(viewController, animated: true, completion: nil)
	}

}
