//
//  Service.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Service {
	public typealias LoginCompletion = (UserInformation?, Error?) -> Void
	
	public func login(from: UIViewController, completion: @escaping LoginCompletion) {}

}

extension Service {
	public struct UserInformation: CustomStringConvertible, Codable {
		public let provider: Provider
		public let userID: String
		public let userName: String
		public let imageURL: URL?
		
		init(provider: Provider, userID: String, userName: String, imageURL: String? = nil) {
			self.provider = provider
			self.userID = userID
			self.userName = userName
			self.imageURL = imageURL == nil ? nil : URL(string: imageURL!)
		}
		
		public var description: String {
			return "\(self.provider) #\(self.userID): \(self.userName)"
		}
	}
}

extension Service {
	public enum Provider: String, Codable { case twitter, facebook, gamecenter, icloud, google, device }
	
	static public private(set) var providers: [Provider] = []
	public static func setup(with providers: [Provider]) {
		self.providers = providers
	}
	
	public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		precondition(!self.providers.isEmpty, "Please add one or more Service Providers before using Identity.")
		if self.providers.contains(.facebook) { Facebook.instance.application(application, didFinishLaunchingWithOptions: launchOptions) }
	}
	
	public static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		if self.providers.contains(.facebook), Facebook.instance.application(app, open: url, options: options) { return true }
		if self.providers.contains(.twitter), Twitter.instance.application(app, open: url, options: options) { return true }

		return false
	}
}