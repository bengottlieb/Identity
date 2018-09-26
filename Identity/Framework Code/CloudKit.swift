//
//  CloudKit.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/2/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import CloudKit


@available(iOSApplicationExtension 10.0, *)
public class CloudKit: Service {
	public static let instance = CloudKit()
	override var provider: Provider { return .cloudkit }

	public func signInAnonymously(from sourceController: UIViewController?, completion: @escaping LoginCompletion) {
		CKContainer.default().fetchUserRecordID { id, error in
			if let id = id {
				self.userInformation = UserInformation(provider: .cloudkit, userID: id.recordName, userName: nil)
				completion(self.userInformation, nil)
			} else {
				completion(nil, error)
			}
		}
	}

	override public var isAvailable: Bool { return Service.providers.contains(.cloudkit) }

	public override func signIn(from sourceController: UIViewController?, completion: @escaping LoginCompletion) {
		CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
			CKContainer.default().fetchUserRecordID { id, error in
				guard let id = id else {
					completion(nil, error)
					return
				}
				CKContainer.default().discoverUserIdentity(withUserRecordID: id) { info, error in
					if let info = info {
						self.userInformation = UserInformation(provider: .cloudkit, userID: id.recordName, userName: info.nameComponents?.givenName, email: info.lookupInfo?.emailAddress)
					} else {
						self.userInformation = UserInformation(provider: .cloudkit, userID: id.recordName, userName: nil, email: nil)
					}
					completion(self.userInformation, error)
				}
			}
		}
	}
}

