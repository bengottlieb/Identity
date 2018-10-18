# Identity #

Identity is a framework that allows you to easily switch between various forms of user identification service: Twitter, Facebook, Google, GameCenter, iCloud, or plain old Email. Its aim is to provide a simple, unified interface to each of these services. 

## Usage ##

### Initial Setup ###

Before using any of Identity's features, you'll need to tell it the services you're interested in, and any keys, client IDs, or secrets required for them. The best place to do this is in your AppDelegate's application(_:didFinishLaunchingWithOptions:) call.

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

	Identity.Service.setup(with: [.cloudkit, .twitter])
	Identity.Twitter.instance.consumerKey = TWITTER_KEY
	Identity.Twitter.instance.consumerSecret = TWITTER_SECRET
	
	Identity.Service.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

You'll also need to add code to your AppDelegate's application(_:open:options) method, to handle any incoming URLs:

```
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if Identity.Service.application(app, open: url, options: options) { return true }

		return false
	}

```

### Services Supported ###
Identity supports five different remote 'services' that can be used to generate a user ID. Each of these is accessed via a singleton. They are:

```
	Identity.Facebook.instance
	Identity.Twitter.instance
	Identity.Google.instance
	Identity.CloudKit.instance
	Identity.GameCenter.instance
```

In addition, you can use Email as a mechanism (you'll need to provide the UI to grab the user's email address) or the device's unique vendor identifier.


### User Interactions ###

When you want your user to choose a sign-in method, you're in charge of creating the selection UI. A frequent mechanism is a series of buttons, one for each service you're interested in.

Note that not all services may be available. For example, if you've chose to use CloudKit/iCloud as a service, and the user has not signed in to iCloud on their device, it won't be available. You can check the availability of any particular service using `Identity.SERVICE_NAME.instance.isAvailable`. You can also listen for the `Identity.Service.Notifications.availabilityChanged` notification for when the availability of a service changes.

To sign in with a particular service, simple call the service singleton's signin(from:completion:) method, passing a view controller and a callback:

```
	Identity.Facebook.instance.signIn(from: self) { result, error in
		if let info = result { print("info: \(info)") }
	}
```

Your callback should take two parameters. The first is an optional UserInformation structure, containing a successful login's results. This will include at least a userID string (unique to that user), and may also have other information, depending on the service, such as name, email, or an avatar image URL.

If the user wants to switch services, you'll want to call signOut() on the service's singleton object: `Identity.Facebook.instance.signOut()`.



