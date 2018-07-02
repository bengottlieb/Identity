//
//  GameCenter.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/2/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation
import GameKit



public class GameCenter: Service {
	public static let instance = GameCenter()
	
	var signinCompletion: LoginCompletion?
	weak var signInController: UIViewController?
	var localPlayerID: String?
	var localPlayerName: String?
	
	override public func fetchFriends(completion: @escaping Service.FetchFriendsCompletion) {
		GKLocalPlayer.localPlayer().loadRecentPlayers() { players, error in
			let friends = players?.compactMap { FriendInformation(gkPlayer: $0) }
			completion(friends, error)
		}
	}
	
	public override func login(from sourceController: UIViewController, completion: @escaping LoginCompletion) {
		assert((Bundle.main.infoDictionary?["UIRequiredDeviceCapabilities"] as? [String])?.contains("gamekit") == true, "Please make sure you've enabled GameKit in your project's Capabilities page")

		self.signinCompletion = completion
		self.signInController = sourceController
		
		GKLocalPlayer.localPlayer().authenticateHandler = { controller, error in
			if let controller = controller {
				sourceController.present(controller, animated: true)
			} else if let error = error {
				print("************** Unable to Connect to Game Center\n\(error)\n***************************************")
				self.signinCompletion?(nil, error)
			} else {
				self.localPlayerID = GKLocalPlayer.localPlayer().playerID
				self.localPlayerName = GKLocalPlayer.localPlayer().alias
				
				self.signinCompletion?(UserInformation(provider: .gamecenter, userID: self.localPlayerID ?? "", userName: self.localPlayerName ?? ""), nil)
			}
			self.signinCompletion = nil
			self.signInController = nil
		}

	}
}
