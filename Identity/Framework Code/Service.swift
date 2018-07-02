//
//  Service.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/1/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import GameKit

public class Service: NSObject {
	public typealias LoginCompletion = (UserInformation?, Error?) -> Void
	public typealias FetchFriendsCompletion = ([FriendInformation]?, Error?) -> Void
	
	public func login(from: UIViewController, completion: @escaping LoginCompletion) {}
	public func fetchFriends(completion: @escaping FetchFriendsCompletion) {}
}

extension Service {
	public struct UserInformation: CustomStringConvertible, Codable {
		public let provider: Provider
		public let userID: String
		public let userName: String?
		public let fullName: String?
		public let email: String?
		public let imageURL: URL?
		
		init(provider: Provider, userID: String, userName: String?, email: String? = nil, fullName: String? = nil, imageURL: String? = nil) {
			self.provider = provider
			self.userID = userID
			self.userName = userName
			self.email = email
			self.fullName = fullName
			self.imageURL = imageURL == nil ? nil : URL(string: imageURL!)
		}
		
		public var description: String {
			return "\(self.provider) #\(self.userID): \(self.userName ?? "")"
		}
	}
	
	public struct FriendInformation: CustomStringConvertible, Codable {
		public let name: String?
		public let userID: String
		
		public var description: String { return "\(self.name ?? "unknown name"): \(self.userID)" }
		
		init?(facebookInfo: [String: Any]) {
			self.name = facebookInfo["name"] as? String
			self.userID = facebookInfo["id"] as? String ?? ""
			if self.userID == "" { return nil }
		}
		
		init?(twitterInfo: [String: Any]) {
			self.name = twitterInfo["name"] as? String
			if let userId = twitterInfo["id"] as? Int {
				self.userID = "\(userId)"
			} else {
				self.userID = ""
				return nil
			}
		}

		init?(gkPlayer: GKPlayer) {
			self.name = gkPlayer.displayName
			self.userID = gkPlayer.playerID ?? ""
			if self.userID.isEmpty { return nil }
		}
	}
}

extension Service {
	public enum Provider: String, Codable { case twitter, facebook, gamecenter, cloudkit, google, device }
	
	static public private(set) var providers: [Provider] = []
	public static func setup(with providers: [Provider]) {
		self.providers = providers
	}
	
	public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		assert(!self.providers.isEmpty, "Please add one or more Service Providers before using Identity.")
		if self.providers.contains(.facebook) { Facebook.instance.application(application, didFinishLaunchingWithOptions: launchOptions) }
		if self.providers.contains(.google) { Google.instance.application(application, didFinishLaunchingWithOptions: launchOptions) }
	}
	
	public static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		if self.providers.contains(.facebook), Facebook.instance.application(app, open: url, options: options) { return true }
		if self.providers.contains(.twitter), Twitter.instance.application(app, open: url, options: options) { return true }
		if self.providers.contains(.google), Google.instance.application(app, open: url, options: options) { return true }

		return false
	}
}

extension Bundle {
	var cfBundleURLs: [String] {
		guard let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else { return [] }
		
		return types.reduce([]) { return $0 + ($1["CFBundleURLSchemes"] as? [String] ?? []) }
	}
}

