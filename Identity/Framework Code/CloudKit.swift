//
//  CloudKit.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/2/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import CloudKit

public class CloudKit: Service {
	public static let instance = CloudKit()

	override public func fetchFriends(completion: @escaping Service.FetchFriendsCompletion) {
	}
	
	public override func login(from sourceController: UIViewController, completion: @escaping LoginCompletion) {
		CKContainer.default().fetchUserRecordID { id, error in
			if let id = id {
				completion(UserInformation(provider: .cloudkit, userID: id.recordName, userName: nil), nil)
			} else {
				completion(nil, error)
			}
		}
	}
}

