//
//  Device.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/2/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Device: Service {
	public static let instance = Device()
	
	enum Error: String, Swift.Error { case unableToFetchVendorID }
	
	public override func login(from sourceController: UIViewController?, completion: @escaping LoginCompletion) {
		if let id = UIDevice.current.identifierForVendor?.uuidString {
			self.userInformation = UserInformation(provider: .device, userID: id, userName: nil, fullName: UIDevice.current.name)
			completion(self.userInformation, nil)
		} else {
			completion(nil, Error.unableToFetchVendorID)
		}
	}
}

