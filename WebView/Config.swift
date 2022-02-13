/************************************************************************************************************************/
//THANKS FOR BEING A PART OF THE WEBVIEWGOLD COMMUNITY - AN EXCELLENT CHOICE WHEN IT COMES TO SUPPORT, POSSIBILITIES, PERFORMANCE, & EASY SETUP! <3 :-)
// *** Your Purchase Code of envato/CodeCanyon ***
// 1. Buy a WebViewGold license (https://www.webviewgold.com/download/iOS) for each app you publish. If your app is going to be
// free, a "Regular License" is required. If your app will be sold to your users or if you use the In-App Purchases API, an
// "Extended License" is required. More info: https://codecanyon.net/licenses/standard?ref=onlineappcreator
// 2. Grab your Purchase Code (this is how to find it quickly: https://help.market.envato.com/hc/en-us/articles/202822600-Where-Is-My-Purchase-Code-)
// 3. Great! Just enter it here and restart your app:
var purchasecode = "xxxxxx-xxxxxx-xxxxxx-xxxxxx-xxxxxx"
// 4. Enjoy your app! :)
//Settings
var host = "example.org" //Set your domain host without http:// or https:// prefixes and without any subdomain like "www."
var webviewurl = "https://www.example.org" //Set your full web app/website URL including http:// or https:// prefix and including subdomains like "www."

var darkmodewebviewurl = "" //This URL will be used if the iOS user activated Dark Mode. Leave empty to use the default URL. To use it, set your full web app/website URL including http:// or https:// prefix and including subdomains like "www."

var uselocalhtmlfolder = false  //Set to "true" to use local "local-www/index.html" file instead of remote URL

var openallexternalurlsinsafaribydefault = false //Set to "true" to open all external hosts in Safari by default

var safariwhitelist = ["alwaysopeninsafari.com",] //Add domains here that should ALWAYS be opened in Safari, regardless of what the openallexternalurlsinsafaribydefault option is set to; to add another domain, insert another host like so: ["alwaysopeninsafari.com", "google.com", "m.facebook.com"] please enter the host exactly how you link to it (with or without www, but always without http/https)

var safariblacklist = [host, "neversopeninsafari.com",] //Add domains here that should NEVER be opened in Safari, regardless of what the openallexternalurlsinsafaribydefault option is set to; to add another domain, insert another host like so: ["alwaysopeninsafari.com", "google.com", "m.facebook.com"] please enter the host exactly how you link to it (with or without www, but always without http/https)

var preventoverscroll = true  //Set to "true" to remove WKWebView bounce animation (recommended for most cases)

var disablecallout = true  //Set to "true" to remove WKWebView 3D touch/callout window for links (recommended for most cases)

var deletecache = false  //Set to "true" to delete the WebView cache with every launch of your app

var okbutton = "OK"  //Set the text label of the "OK" buttons of dialogs

var bigstatusbar = false //Set to "true" to enhance the Status Bar size

var useloadingsign = true //Set to "false" to hide the loading sign while loading your URL

var hideverticalscrollbar = false //Set to "false" to hide the vertical scrollbar

var hidehorizontalscrollbar = false //Set to "false" to hide the horizontal scrollbar

var enableswipenavigation = true //Set to false to prevent swipe left and swipe right from triggering backward and forward page navigation

var orientationiphone = "auto" // set the orientation to either "portrait", "landscape", or "auto"

var orientationipad = "auto" // set the orientation to either "portrait", "landscape", or "auto"

//Custom User Agent for WebView Requests
var useragent_iphone = ""  //Set a customized UserAgent on iPhone (or leave it empty to use the default iOS iPhone UserAgent)

var useragent_ipad = ""  //Set a customized UserAgent on iPad (or leave it empty to use the default iOS iPad UserAgent)

//"First Run" Alert Box
var activatefirstrundialog = true  //Set to "true" to activate the "First run" dialog

var firstrunmessagetitle = "Welcome!"  //Set the title label of the "First run" dialog

var firstrunmessage = "Thank you for downloading this app!" //Set the text label of the "First run" dialog

var askforpushpermissionatfirstrun = true //Set to "true" to ask your users for push notifications permission at the first run of your application in general (for OneSignal, Firebase, and JavaScript API). Set it to "false" to never ask or to ask with a registerpush:// URL call in your web app later

//Offline Screen and Dialog
var offlinetitle = "Connection error"  //Set the title label of the Offline dialog

var offlinemsg = "Please check your connection."  //Set the text of the Offline dialog

var screen1 = "Connection down?"  //Set the text label 1 of the Offline screen

var screen2 = "WiFi and mobile data are supported."  //Set the text label 2 of the Offline screen

var autoreconnecttext = "Attemping to reconnect..."

var offlinebuttontext = "Try again now"  //Set the text label of the "Try again" button

//"Rate this app on App Store" Dialog
var activateratemyappdialog = true  //Set to "true" to activate the "Rate this app on App Store" dialog

//"Follow on Facebook" Dialog
var activatefacebookfriendsdialog = false  //Set to "true" to activate the "Follow on Facebook" dialog

var becomefacebookfriendstitle = "Stay tuned"  //Set the title label of the "Follow on Facebook" dialog

var becomefacebookfriendstext = "Become friends on Facebook?" //Set the text label of the "Follow on Facebook" dialog

var becomefacebookfriendsyes = "Yes" //Set the text label of the "Yes" button of the "Follow on Facebook" dialog

var becomefacebookfriendsno = "No" //Set the text label of the "No" button of the "Follow on Facebook" dialog

var becomefacebookfriendsurl = "https://www.facebook.com/OnlineAppCreator/" //Set the URL of your Facebook page


//Image Downloader API
var imagedownloadedtitle = "Image saved to your photo gallery."  //Set the title label of the "Image saved to your photo gallery" dialog box

var imagenotfound = "Image not found."  //Set the title label of the "Image not found" dialog box

//Custom Status Bar Design
var statusbarbackgroundcolor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Define a custom status bar background color

var darkmodestatusbarbackgroundcolor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Define a custom status bar background color while user is using iOS Dark Mode

var statusbarcolor = "black" //Define the text color of the status bar ("white" or "black"); requires iOS 13 or higher

var darkmodestatusbarcolor = "black" //Define the text color of the status bar ("white" or "black")  while user is using iOS Dark Mode; requires iOS 13 or higher

//Set to "true" to prevent the device from going into sleep while the app is active
var preventsleep = false

//QR Code Scanner Configuration
var qrcodelinks = "0" //Set to 0 to open QR Code links in your own main window; set to 1 to open the links in a new popup; set to 2 to open QR Code links in Safari

//Universal Links & Deeplinking
var ShowExternalLink = false //Set to "true" to register an iOS-wide URL scheme (like WebViewGold://) to open links in WebView app from other apps; example format: WebViewGold://url?link=https://www.google.com (would open google.com in WebView app). Please change the URL scheme from WebViewGold:// to YOUR-APP-NAME:// in Info.plist (further information in the documentation)

var remainSplashOption = false //Set to "true" if you want to display the Splash Screen until your page was loaded successfully

//Custom CSS
let cssString = "" //Set any CSS classes to inject them into the HTML rendered by the WebView. Leave empty to not inject custom CSS into your webpage when accessed in WebView

//Alert Message
public struct AlertMessage{
    static let dataMissing = "Something went wrong. Please try again."
}

public struct Constants {
static let appendlanguage = false //Set to true if you want to extend URL request by the system language like ?webview_language=LANGUAGE CODE (e.g., ?webview_language=EN for English users)
    
static let offlinelocalhtmlswitch = false //Set to true if you want to use the "local-html" folder if the user is offline, and use the remote URL if the user is online
    
static let extentionARY:NSArray = ["pdf","mp3","mp4","wav","epub","pkpass","pptx","ppt","doc","docx","xlsx","ics"] //Add the file formats that should trigger the file downloader functionality (e.g., .pdf, .docx, ...)
    
static let loadingSigncolor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) //Set a color for the loading sign indicator
    
static let splshscreencolor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Set a background color for the splash screen
    
//In-App Purchase and In-App Subscription Settings (details can be configured in App Store Connect)
static let InAppPurchAppBundleIdentifier = "com.webviewgold.IAPProduct" //Default In-App Purchase Bundle Identifier

static var IAPSharedSecret = "6d2496d573c246cdb4bbe0e0595a8f49" //Default In-App Purchase Shared Secret

static let iapsuccessurl = "https://www.google.com/" //Default In-App Purchase/In-App Subscription Success URL

static let iapexpiredurl = "https://www.yahoo.com/" //Default In-App Subscription Expired URL

//OneSignal Push Configuration
static let oneSignalID = "d5a155ae-c86e-4dc0-abef-095598132cb7"; //Enter your OneSignal App ID here

static let kPushEnabled         = false; //Set to true to activate the OneSignal push functionality (set oneSignalID first)

static let kPushEnhanceUrl      = false; //Set to true if you want to extend WebView Main URL requests by ?onesignal_push_id=XYZ

static let kPushReloadOnUserId  = false; //Set to true if WebView should be reloaded after receiving the UserID from OneSignal

static let kPushOpenDeeplinkInBrowser  = false; //Set to true to open deeplinking URLs from OneSignal in the Safari browser instead of the main WebView; Important: For sending notifications with a link from OneSignal, do NOT use 'Launch URL' instead, you must use an 'Additional Data Field', with key: url and value: the link you want to use. See WebViewGold documentation for more information.
    
//Firebase Push Configuration
static let kFirebasePushEnabled   = false; //Set to true to activate the Firebase push functionality (before activating, please download and replace Google-ServiceInfo.plist from Firebase Dashboard)

static let kFirebaseEnhanceUrl   = false; //Set to true if you want to extend WebView Main URL requests by ?firebase_push_id=XYZ
    
//AdMob Ads Configuration
static var AdmobBannerID = "ca-app-pub-3940256099942544/2934735716" //Set the AdMob ID for banner ads

static var AdmobinterstitialID = "ca-app-pub-3940256099942544/4411468910" //Set the AdMob ID for interstitial ads

static let showBannerAd = false //Set to "true" to activate AdMob banner ads

static let showFullScreenAd = false //Set to "true" to activate AdMob interstitial full-screen ads after X website clicks

static var showadAfterX = 5 //Show AdMob interstitial ads each X website requests/loads
    

//Facebook Interstitial Ads
static var useFacebookAds = false //Set to true to activate Facebook Interstitial Ads

static let facebookAdsID = "XXXXXXXXXXXXXXX_XXXXXXXXXXXXX" //Enter your Placement ID, available when you create a property on Facebook Monetization manager, and connect an iOS app. The ID will look like this: 3937960198956424_3969441893142587
    
static let useTimedAds = true //Use timed ads for Facebook Ads (e.g., every 60s) as opposed to ads every X clicks
    
static let showFBAdsEveryNSeconds : Double = 30 //Show a Facebook Interstitial Ad every X seconds


//Other
static let AppBundleIdentifier = Bundle.main.bundleIdentifier
static let kAppDelegate         = UIApplication.shared.delegate as! AppDelegate
static let kUserDefaults        = UserDefaults.standard
static let kScreenWidth         = UIScreen.main.bounds.width
static let kScreenHeight        = UIScreen.main.bounds.height
static let kAppDisplayName      = UIApplication.appName
static let kAppVersion          = UIApplication.shortVersionString
static let kCountryCode         = UIApplication.countryCode
static let kCalendar            = Calendar.current
static let kDeviceType          = "ios"
static let kSystemVersion       = UIDevice.current.systemVersion
static let kModel               = UIDevice.current.model
static let kDeviceId            = UIDevice.current.identifierForVendor!.uuidString
}
