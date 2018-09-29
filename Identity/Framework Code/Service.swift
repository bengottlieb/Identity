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
	static public var defaults = UserDefaults.standard
	
	var identityDefaultsKey: String { return "identity-\(self.provider.rawValue)" }
	static let currentIdentityKey = "identity-current"
	
	public struct Notifications {
		static public let availabilityChanged = Notification.Name("Identity-availabilityChanged")
	}
	
	public var isCurrent: Bool {
		get { return Service.defaults.string(forKey: Service.currentIdentityKey) == self.identityDefaultsKey }
		set {
			if newValue {
				Service.defaults.set(self.identityDefaultsKey, forKey: Service.currentIdentityKey)
			} else {
				Service.defaults.removeObject(forKey: Service.currentIdentityKey)
			}
		}
	}
	
	public var userInformation: UserInformation? { didSet {
		if let info = self.userInformation, let data = try? JSONEncoder().encode(info) {
			Service.defaults.set(data, forKey: self.identityDefaultsKey)
		} else {
			if self.isCurrent { isCurrent = false }
			Service.defaults.removeObject(forKey: self.identityDefaultsKey)
		}
	}}
	
	override init() {
		super.init()
		if let data = Service.defaults.data(forKey: self.identityDefaultsKey) {
			if let userInfo = try? JSONDecoder().decode(UserInformation.self, from: data), userInfo.provider == self.provider { self.userInformation = userInfo }
		}
	}
	
	public var isAvailable: Bool { return true }
	public var isSignedIn: Bool { return self.userInformation != nil }
	var provider: Provider { return .none }
	
	public typealias LoginCompletion = (UserInformation?, Error?) -> Void
	public typealias FetchFriendsCompletion = ([FriendInformation]?, Error?) -> Void
	
	public func signIn(from: UIViewController?, completion: @escaping LoginCompletion) {}
	public func fetchFriends(completion: @escaping FetchFriendsCompletion) {}
	
	public func signOut() {
		self.userInformation = nil
	}
	
	func setup() { }
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
			self.userID = gkPlayer.playerID
			if self.userID.isEmpty { return nil }
		}
	}
}

extension Service {
	public enum Provider: String, Codable { case none, email, twitter, facebook, gamecenter, cloudkit, google, device, anonymous
		
		public var title: String? {
			switch self {
			case .none: return NSLocalizedString("none", comment: "none")
			case .email: return NSLocalizedString("Email", comment: "email")
			case .twitter: return NSLocalizedString("Twitter", comment: "Twitter")
			case .facebook: return NSLocalizedString("Facebook", comment: "Facebook")
			case .gamecenter: return NSLocalizedString("Game Center", comment: "Game Center")
			case .cloudkit: return NSLocalizedString("iCloud", comment: "iCloud")
			case .google: return NSLocalizedString("Google", comment: "Google")
			case .device, .anonymous: return nil
			}
		}
		
		public var mainColor: UIColor {
			switch self {
			case .none: return .white
			case .email: return .darkGray
			case .twitter: return UIColor(red:0.25, green:0.76, blue:0.93, alpha:1.0)
			case .facebook: return UIColor(red:0.26, green:0.42, blue:0.69, alpha:1.0)
			case .gamecenter: return UIColor(red:0.38, green:0.66, blue:0.37, alpha:1.0)
			case .cloudkit: return UIColor(red:0.06, green:0.22, blue:0.38, alpha:1.0)
			case .google: return UIColor(red:0.98, green:0.73, blue:0.18, alpha:1.0)
			case .device: return .white
			case .anonymous: return .black
			}
		}

		public var textColor: UIColor {
			switch self {
			case .none: return .black
			case .email: return .white
			case .twitter: return .black
			case .facebook: return .white
			case .gamecenter: return .white
			case .cloudkit: return .white
			case .google: return .black
			case .device: return .black
			case .anonymous: return .white
			}
		}
	}
	
	public static func service(for provider: Provider?) -> Service? {
		guard let provider = provider else { return nil }
		switch provider {
		case .none: return nil
		case .email: return nil
		case .twitter: return Twitter.instance
		case .facebook: return Facebook.instance
		case .gamecenter: return GameCenter.instance
		case .cloudkit:
			if #available(iOSApplicationExtension 10.0, *) {
				return CloudKit.instance
			} else {
				return nil
			}
			
		case .google: return Google.instance
		case .device: return Device.instance
		case .anonymous:
			if #available(iOSApplicationExtension 10.0, *) {
				return Anonymous.instance
			} else {
				return nil
			}
		}
	}
	
	static public private(set) var providers: [Provider] = []
	public static func setup(with providers: [Provider]) {
		self.providers = providers
		for provider in providers {
			self.service(for: provider)?.setup()
		}
	}
	
	public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
		assert(!self.providers.isEmpty, "Please add one or more Service Providers before using Identity.")
		if self.providers.contains(.facebook) { Facebook.instance.application(application, didFinishLaunchingWithOptions: launchOptions) }
		if self.providers.contains(.google) { Google.instance.application(application, didFinishLaunchingWithOptions: launchOptions) }
	}
	
	public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if self.providers.contains(.facebook), Facebook.instance.application(app, open: url, options: options) { return true }
		if self.providers.contains(.twitter), Twitter.instance.application(app, open: url, options: options) { return true }
		if self.providers.contains(.google), Google.instance.application(app, open: url, options: options) { return true }

		return false
	}
}

extension Bundle {
	var cfBundleURLs: [String] {
		var schemes = Bundle.main.infoDictionary?["CFBundleURLSchemes"] as? [String] ?? []

		if let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
			schemes += types.reduce([]) { return $0 + ($1["CFBundleURLSchemes"] as? [String] ?? []) }
		}
		
		return schemes
	}
}

