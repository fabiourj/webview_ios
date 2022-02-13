//  OnlineAppCreator.com
//  WebViewGold for iOS // webviewgold.com

/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */

import UIKit
import AVFoundation
import UserNotifications
import WebKit
import StoreKit
import OneSignal
import GoogleMobileAds
import StoreKit
import SafariServices
import SwiftQRScanner
import SwiftyStoreKit
import FBAudienceNetwork
import AppTrackingTransparency
protocol IAPurchaceViewControllerDelegate
{
    func didBuyColorsCollection(collectionIndex: Int)
}
var  AdmobBannerID = Constants.AdmobBannerID
var AdmobinterstitialID = Constants.AdmobinterstitialID
var showBannerAd = Constants.showBannerAd
var showFullScreenAd = Constants.showFullScreenAd
var showadAfterX = Constants.showadAfterX
var deeplinkingrequest = false
var usemystatusbarbackgroundcolor = true

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
extension String {
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
}



class WebViewController: UIViewController, OSSubscriptionObserver, GADBannerViewDelegate, GADInterstitialDelegate, SKStoreProductViewControllerDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver, FBInterstitialAdDelegate
{
    @IBOutlet var loadingSign: UIActivityIndicatorView!
    @IBOutlet var offlineImageView: UIImageView!
    @IBOutlet var lblText1: UILabel!
    @IBOutlet var lblText2: UILabel!
    @IBOutlet var lblText3: UILabel!
    @IBOutlet var btnTry: UIButton!
    @IBOutlet var statusbarView: UIView!
    @IBOutlet weak var bgView: UIImageView!
    
    var webView: WKWebView!
    var safariWebView: SFSafariViewController!
    var first_statusbarbackgroundcolor = statusbarbackgroundcolor
    
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var isFirstTimeLoad = true
    var extendediap = true
    var localCount = 0
    var offlineswitchcount = 0
    var firsthtmlrequest = "true"
    
    var delegate: IAPurchaceViewControllerDelegate!
    
    var transactionInProgress = false
    var selectedProductIndex: Int!
    
    var productIDs: Array<String?> = []
    
    var productsArray: Array<SKProduct?> = []
    
    var interstitialAd: FBInterstitialAd!
    let fbInterstitialAdID: String = Constants.facebookAdsID
    var timer1: Timer?
    var activeFBAd = false
    
    
    // ORIENTATIONS
    override func viewDidAppear(_ animated: Bool) {
        
            var orientation = ""
            
            //if IPAD
            if ( UIDevice.current.userInterfaceIdiom == .pad){
              orientation = orientationipad
            } else  if ( UIDevice.current.userInterfaceIdiom == .phone) {
                orientation = orientationiphone
            }
            
            if orientation == "portrait" {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                AppDelegate.AppUtility.lockOrientation(.portrait)
            }
            
            else if orientation == "landscape" {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                AppDelegate.AppUtility.lockOrientation(.landscapeLeft)
            }
        
    }
    
//
//    // Specify the orientation.
//    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//       return .landscapeLeft
//    }
//

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
       
        if #available(iOS 14, *) {
            print("ADS AUTH STATUS",ATTrackingManager.trackingAuthorizationStatus.rawValue)
            if(ATTrackingManager.trackingAuthorizationStatus.rawValue == 2){
               
                //DISABLE AD LIBRARIES:
                Constants.useFacebookAds = false;
                showBannerAd = false;
                showFullScreenAd = false;
                
                //DISABLE ALL ADS
                
            }
        }
        
//        ads will display every after n sec
        if(Constants.useFacebookAds == true && Constants.useTimedAds){
            timer1 = Timer.scheduledTimer(withTimeInterval: Constants.showFBAdsEveryNSeconds, repeats: true, block: { (timer) in
                
                print("Exists an active FB Ad?", self.activeFBAd)
                if( self.activeFBAd == false) {
                    self.DisplayAd()
                }
                self.activeFBAd = true
                
            })
        }
        if #available(iOS 13.0, *)
        {
            if self.traitCollection.userInterfaceStyle == .light {
                if (statusbarcolor == "white"){
                    self.navigationController!.navigationBar.barStyle = .black
                }
            }
            
            if self.traitCollection.userInterfaceStyle == .dark {
                statusbarbackgroundcolor = darkmodestatusbarbackgroundcolor
                if darkmodewebviewurl.isEqual("")
                {
                }
                else
                {
                    webviewurl = darkmodewebviewurl
                }
                if (darkmodestatusbarcolor == "black"){
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.deactivatedarkmode()
                }
            }
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.isHidden = true
        selectedProductIndex = 0
        
        
        
        let langStr = Locale.current.languageCode
        loadingSign.color = Constants.loadingSigncolor
        if Constants.appendlanguage == true{
            
            if webviewurl != ""{
                if let range:Range<String.Index> = webviewurl.range(of: "?") {
                    webviewurl = "\(webviewurl)&webview_language=\(langStr!)"
                }else{
                    webviewurl = "\(webviewurl)?webview_language=\(langStr!)"
                }
                
            }
        }
        
        print(webviewurl)
        bgView.isHidden = true
        if (remainSplashOption) {
            loadingSign.isHidden = true
            bgView.isHidden = false
            bgView.image = UIImage.gifImageWithName("splash")
            self.statusbarView.backgroundColor = Constants.splshscreencolor
            view.backgroundColor = Constants.splshscreencolor
        }
        
        productIDs.append(Constants.AppBundleIdentifier)
        
        requestProductInfo()
        
        
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(OpenWithExternalLink), name: NSNotification.Name(rawValue: "OpenWithExternalLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Open_NotificationUrl), name: NSNotification.Name(rawValue: "OpenWithNotificationURL"), object: nil)
        var osURL = purchasecode;
        localCount = 0
        if showBannerAd {
            bannerView.isHidden = false
            bannerView.adUnitID = AdmobBannerID
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }else{
            bannerView.isHidden = true
        }
        if showFullScreenAd && !Constants.useFacebookAds {
            interstitial = createAndLoadInterstitial()
        }
        
        isFirstTimeLoad = true
        
        if(Constants.kPushEnabled)
        {
            OneSignal.add(self as OSSubscriptionObserver)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
        }
        catch {
        }
        
        
        //Ensures that app has custom idle settings (dark screen)
        UIApplication.shared.isIdleTimerDisabled = preventsleep;
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if useragent_iphone.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_iphone
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
            
        case .pad:
            if useragent_ipad.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_ipad
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
            
        case .unspecified:
            if useragent_iphone.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_iphone
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
        case .tv:
            print("tv");
        case .carPlay:
            print("carplay");
        case .mac:
            break
        @unknown default:
            break
        }
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        addWebViewToMainView(webView)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if useragent_iphone.isEqual("")
            {
                
            }
            else
            {
                webView.customUserAgent = useragent_iphone
            }
        case .unspecified:
            break
        case .pad:
            if useragent_ipad.isEqual("")
            {
                
            }
            else
            {
                webView.customUserAgent = useragent_ipad
            }
        case .tv:
            break
        case .carPlay:
            break
        case .mac:
            break
        @unknown default:
            break
        }
        let defaults = UserDefaults.standard
        let age = defaults.integer(forKey: "age")
        let savedOSurl = defaults.string(forKey: "osURL")
        let savedOSurltwo = defaults.string(forKey: "osURL2")
        #if DEBUG
        if (age != 1 || savedOSurl != osURL){
            self.download(deep: osURL)
        }
        if (savedOSurltwo == "1"){
            self.extendediap = false
        }
        #endif
        let phonecheck = UIScreen.main.bounds
        let statusbar: CGFloat = 20
        
        if phonecheck.size.height == 667 - statusbar
        {
            offlineImageView.frame = CGRect(x: CGFloat(103), y: CGFloat(228), width: CGFloat(170), height: CGFloat(170))
            lblText1.frame = CGRect(x: CGFloat(40), y: CGFloat(400), width: CGFloat(295), height: CGFloat(50))
            lblText2.frame = CGRect(x: CGFloat(25), y: CGFloat(435), width: CGFloat(326), height: CGFloat(50))
            lblText3.frame = CGRect(x: CGFloat(25), y: CGFloat(435), width: CGFloat(326), height: CGFloat(50))
            btnTry.frame = CGRect(x: CGFloat(110), y: CGFloat(520), width: CGFloat(150), height: CGFloat(20))
        }
        
        if phonecheck.size.height == 736 - statusbar
        {
            offlineImageView.frame = CGRect(x: CGFloat(123), y: CGFloat(205), width: CGFloat(170), height: CGFloat(170))
            lblText1.frame = CGRect(x: CGFloat(60), y: CGFloat(346), width: CGFloat(295), height: CGFloat(50))
            lblText2.frame = CGRect(x: CGFloat(44), y: CGFloat(374), width: CGFloat(326), height: CGFloat(50))
            lblText3.frame = CGRect(x: CGFloat(44), y: CGFloat(374), width: CGFloat(326), height: CGFloat(50))
            btnTry.frame = CGRect(x: CGFloat(132), y: CGFloat(453), width: CGFloat(150), height: CGFloat(20))
        }
        
        if #available(iOS 13.0, *)
        {
            if self.traitCollection.userInterfaceStyle != .dark {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        let url = URL(string: webviewurl)!
        host = url.host ?? ""
        
        if (preventoverscroll)
        {
            self.webView.scrollView.bounces = false
        }
        if (hideverticalscrollbar)
        {
            webView.scrollView.showsVerticalScrollIndicator = false
        }
        if (hidehorizontalscrollbar)
        {
            webView.scrollView.showsHorizontalScrollIndicator = false
        }
        if (deletecache)
        {
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.removeAllCachedResponses()
            let config = WKWebViewConfiguration()
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            config.allowsInlineMediaPlayback = true
            config.mediaTypesRequiringUserActionForPlayback = []
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
            
        }
        
        view.bringSubviewToFront(loadingSign)
        
        webView.scrollView.bouncesZoom = false
        webView.allowsLinkPreview = false
        webView.autoresizingMask = ([.flexibleHeight, .flexibleWidth])
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        offlineImageView.isHidden = true
        loadingSign.stopAnimating()
        loadingSign.isHidden = true
        btnTry.setTitle(offlinebuttontext, for: .normal)
        btnTry.setTitle(offlinebuttontext, for: .selected)
        lblText1.text = screen1
        lblText2.text = screen2
        lblText3.text = autoreconnecttext
        
        lblText1.isHidden = true
        lblText2.isHidden = true
        lblText3.isHidden = true
        btnTry.isHidden = true
        
        timer?.invalidate()
        
        let onlinecheck = url.absoluteString
        
        if (uselocalhtmlfolder)
        {
            let urllocal = URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
            webView.load(URLRequest(url: urllocal))
        }
        else
        {
            if onlinecheck.count == 0
            {
                offlineImageView.isHidden = false
                webView.isHidden = true
                lblText1.isHidden = false
                lblText2.isHidden = false
                lblText3.isHidden = false
                btnTry.isHidden = false
                loadingSign.isHidden = false
                if (usemystatusbarbackgroundcolor)
                {
                    self.statusbarView.backgroundColor = .white
                    view.backgroundColor = .white
                }
                print("Test1")
                
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
                
            }
            else
            {
                loadWeb()
            }
        }
        self.perform(#selector(checkForAlertDisplay), with: nil, afterDelay: 0.5)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if UserDefaults.standard.value(forKey: "IsPurchase")as! String == "YES"
        {
            receiptValidation()
        }
    }
    
    @IBAction func AppInPurchaseBtnAction(_ sender: Any)
    {
        showActions(str: "Testing")
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments()
        {
            
            let productIdentifiers = NSSet(array: productIDs as [Any])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as Set<NSObject> as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else
        {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
        }
        else {
            print("There are no products.")
        }
    }
    
    func showActions(str:String)
    {
        let str1 = str.slice(from: "=", to: "&")// "package="
        if str1 == nil{
            return
        }
        let package = str1!
        
        var sucessuri = "no"
        var expireduri = "no"
        
        if let range:Range<String.Index> = str.range(of: "expired_url=") {
            let index: Int = str.distance(from: str.startIndex, to: range.lowerBound)
            let firstindex = index + 12
            expireduri = str[firstindex..<str.count]
            sucessuri = str.slice(from: "successful_url=", to: "&")!
        }else{
            let range1:Range<String.Index> = str.range(of: "successful_url=")!
            let index: Int = str.distance(from: str.startIndex, to: range1.lowerBound)
            let firstindex = index + 15
            sucessuri = str[firstindex..<str.count]
        }
        self.purchase(packgeid: package, atomically: false, succesurl: sucessuri, expireurl: expireduri)
        
    }
    
    func purchase(packgeid:String, atomically: Bool,succesurl:String,expireurl:String) {
        
        //NetworkActivityIndicatorManager.networkOperationStarted()
        print(packgeid)
        SwiftyStoreKit.purchaseProduct(packgeid, atomically: atomically) { [self] result in
            //NetworkActivityIndicatorManager.networkOperationFinished()
            print(result)
            var checkstatus = false
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                checkstatus = true
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if case .error(let error) = result {
                print(error)
            }
            
            if checkstatus == true{
                let succesurl2 = URL (string: succesurl)
                let requestObj2 = URLRequest(url: succesurl2!)
                self.webView.load(requestObj2)
            }else{
                print(expireurl)
                if expireurl != "no"{
                    let expireurl2 = URL (string: expireurl)
                    let expireurl2obj = URLRequest(url: expireurl2!)
                    self.webView.load(expireurl2obj)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
                UserDefaults.standard.setValue("YES", forKey: "IsPurchase")
                
                let url = URL (string: Constants.iapsuccessurl)
                let requestObj = URLRequest(url: url!)
                bannerView.isHidden = true
                webView.load(requestObj)
                
            case SKPaymentTransactionState.failed:
                print("Transaction failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                UserDefaults.standard.setValue("NO", forKey: "IsPurchase")
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController)
    {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func OpenWithExternalLink()
    {
        if (ShowExternalLink){
            let user = UserDefaults.standard
            if user.url(forKey: "DeepLinkUrl") != nil{
                let str = user.value(forKey: "DeepLinkUrl") as! String
                var newurl = str.replacingOccurrences(of: "www.", with: "")
                newurl = newurl.replacingOccurrences(of: "https://", with: "")
                newurl = newurl.replacingOccurrences(of: "http://", with: "")
                
                host = newurl
                webviewurl = "\(user.value(forKey: "DeepLinkUrl") ?? "")"
                loadWeb()
            }
        }
    }
    
    @objc func Open_NotificationUrl()
    {
        let user = UserDefaults.standard
        if user.url(forKey: "Noti_Url") != nil{
            let str = user.value(forKey: "Noti_Url") as! String
            var newurl = str.replacingOccurrences(of: "www.", with: "")
            newurl = newurl.replacingOccurrences(of: "https://", with: "")
            newurl = newurl.replacingOccurrences(of: "http://", with: "")
            
            if (Constants.kPushOpenDeeplinkInBrowser){
                let url3 = URL (string: str)
                self.open(scheme: url3!)
                loadWeb()
            }
            else {
                host = newurl
                webviewurl = "\(user.value(forKey: "Noti_Url") ?? "")"
                loadWeb()
            }
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial
    {
        var interstitial = GADInterstitial(adUnitID: AdmobinterstitialID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {
        interstitial = createAndLoadInterstitial()
    }
    
    func presentInterstitial()
    {
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("adViewDidReceiveAd")
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError)
    {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillPresentScreen")
    }
    
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewDidDismissScreen")
    }
    
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView)
    {
        print("adViewWillLeaveApplication")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @objc func startTimer() {
        clickToBtnTry(1)
    }
    
    var timer: Timer?
    
    @IBAction func clickToBtnTry(_ sender: Any)
    {
        offlineImageView.isHidden = true
        lblText1.isHidden = true
        lblText2.isHidden = true
        lblText3.isHidden = true
        btnTry.isHidden = true
        loadingSign.isHidden = false
        loadingSign.startAnimating()
        
        timer?.invalidate()
        
        webView.isHidden = false
        if (usemystatusbarbackgroundcolor)
        {
            self.statusbarView.backgroundColor = statusbarbackgroundcolor
            view.backgroundColor = statusbarbackgroundcolor
        }
        loadWeb()
    }
    
    func loadWeb()
    {
        var urlEx = "";
        var urlEx2 = "";
        
        //OneSignal
        if(Constants.kPushEnabled)
        {
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            
            if(Constants.kPushEnhanceUrl && userID != nil && userID!.count > 0)
            {
                urlEx = String(format: "%@onesignal_push_id=%@", (webviewurl.contains("?") ? "&" : "?"), userID!);
            }
        }
        var url = URL(string: webviewurl + urlEx)!
        
        //Firebase
        if(Constants.kFirebasePushEnabled)
        {
        let defaults = UserDefaults.standard
        let FirebaseID = defaults.string(forKey: "FirebaseID")
        if(Constants.kFirebaseEnhanceUrl && FirebaseID != nil && FirebaseID!.count > 0)
        {
            urlEx2 = String(format: "%@firebase_push_id=%@", (url.absoluteString.contains("?") ? "&" : "?"), FirebaseID!);
        }
        }
        url = URL(string: url.absoluteString + urlEx2)!
        
        let request = URLRequest(url: url)
        deeplinkingrequest = true
        
        if InternetConnectionManager.isConnectedToNetwork(){
            webView.load(request)
        }else{
            let url = Bundle.main.url(forResource: "index", withExtension:"html")
            webView.load(URLRequest(url: url!))
        }
        
        
        
    }
    
    func download(deep osURL: String)
    {
        DispatchQueue.global().async {
            do
            {
                let default0 = "aHR0cHM6Ly93d3cud2Vidmlld2dvbGQuY29tL3ZlcmlmeS1hcGkvP2NvZGVjYW55b25fYXBwX3RlbXBsYXRlX3B1cmNoYXNlX2NvZGU9"
                let defaulturl = default0.base64Decoded()
                let combined2 = defaulturl! + osURL
                let data = try Data(contentsOf: URL(string: combined2)!)
                
                DispatchQueue.global().async { [self] in
                    DispatchQueue.global().async {
                    }
                    
                    let mystr = String(data: data, encoding: String.Encoding.utf8) as String?
                    
                    let textonos = "UGxlYXNlIGVudGVyIGEgdmFsaWQgQ29kZUNhbnlvbiBwdXJjaGFzZSBjb2RlIGluIFdlYlZpZXdDb250cm9sbGVyLnN3aWZ0IGZpbGUuIE1ha2Ugc3VyZSB0byB1c2Ugb25lIGxpY2Vuc2Uga2V5IHBlciBwdWJsaXNoZWQgYXBwLg=="
                    
                    if (mystr?.contains("0000-0000-0000-0000"))! {
                        
                        let alertController = UIAlertController(title: textonos.base64Decoded(), message: nil, preferredStyle: UIAlertController.Style.alert)
                        
                        
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                        
                    }
                    else{
                        let defaults = UserDefaults.standard
                        defaults.set("0", forKey: "osURL2")
                        self.extendediap = true
                        if (mystr?.contains("UmVndWxhcg==".base64Decoded()!))! {
                            self.extendediap = false
                            defaults.set("1", forKey: "osURL2")
                        }
                        
                        defaults.set(1, forKey: "age")
                        defaults.set(osURL, forKey: "osURL")
                    }
                }
                
            }
            catch
            {
                
            }
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!)
    {
        if Constants.kPushEnabled && !stateChanges.from.subscribed && stateChanges.to.subscribed
        {
            print("Subscribed to OneSignal push notifications")
            
            if(Constants.kPushReloadOnUserId)
            {
                loadWeb();
            }
        }
        
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    
    func receiptValidation()
    {
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!)
        {
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) //.URLEncoded
            let dict = ["receipt-data":receiptString, "password":Constants.IAPSharedSecret] as [String : Any]
            var jsonData:Data?
            do{
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            let receiptURL = Bundle.main.appStoreReceiptURL!
            
            let storeURL = NSURL(string:"https://buy.itunes.apple.com/verifyReceipt")!
            
            let IsSandbox: Bool = receiptURL.absoluteString.hasSuffix("sandboxReceipt")
            
            if(IsSandbox == true){
                print("IAP SANDBOX")
                let storeURL = NSURL(string:"https://sandbox.itunes.apple.com/verifyReceipt")!
            }
            
            let storeRequest = NSMutableURLRequest(url: storeURL as URL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = jsonData!
            let session = URLSession(configuration:URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest as URLRequest) { data, response, error in
                do{
                    let jsonResponse:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(jsonResponse)
                    
                    let expirationDate:Date = self.getExpirationDateFromResponse(jsonResponse) ?? Date().addingTimeInterval(86400)
                    
                    
                    print(expirationDate)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                    let strPurchaseDate : String = dateFormatter.string(from: Date())
                    let CurentDate : Date = dateFormatter.date(from: strPurchaseDate)!
                    
                    if CurentDate > expirationDate as Date
                    {
                        DispatchQueue.main.async
                        {
                            let url = URL(string: Constants.iapexpiredurl)!
                            let request = URLRequest(url: url)
                            self.webView.load(request)
                        }
                    }
                }
                catch{
                    print("ERROR: " + error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.firstObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            if let expiresDate = lastReceipt["expires_date"] as? String {
                return formatter.date(from: expiresDate)
            }
            
            return nil
        }
        else {
            return nil
        }
    }
    
}

extension String
{
    func base64Encoded() -> String?
    {
        if let data = self.data(using: .utf8)
        {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String?
    {
        if let data = Data(base64Encoded: self)
        {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension WKWebView
{
    override open var safeAreaInsets: UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension WebViewController
{
    @objc func checkForAlertDisplay()
    {
        let user = UserDefaults.standard
        srandom(UInt32(time(nil)))
        
        let randnum = arc4random() % 10
        
        if (activateratemyappdialog) {
            if !user.bool(forKey: "ratemyapp")
            {
                if randnum == 1
                {
                    if #available( iOS 10.3,*){
                        SKStoreReviewController.requestReview()
                        user.set("1", forKey: "ratemyapp")
                        user.synchronize()
                    }
                }
            }
        }
        if (activatefacebookfriendsdialog) {
            if !user.bool(forKey: "becomefbfriends")
            {
                if randnum == 2
                {
                    user.set("1", forKey: "becomefbfriends")
                    user.synchronize()
                    
                    let alertController = UIAlertController(title: becomefacebookfriendstitle, message: becomefacebookfriendstext, preferredStyle: UIAlertController.Style.alert)
                    
                    let yesAction = UIAlertAction(title: becomefacebookfriendsyes, style: UIAlertAction.Style.default, handler: {
                        alert -> Void in
                        
                        let prefeedback = becomefacebookfriendsurl
                        let feedback = URL(string: prefeedback)!
                        self.open(scheme: feedback)
                        
                    })
                    
                    let noAction = UIAlertAction(title: becomefacebookfriendsno, style: UIAlertAction.Style.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(yesAction)
                    alertController.addAction(noAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        if (activatefirstrundialog) {
            if !user.bool(forKey: "firstrun")
            {
                user.set("1", forKey: "firstrun")
                user.synchronize()
                
                let alertController = UIAlertController(title: firstrunmessagetitle, message: firstrunmessage, preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func downloadImageAndSave(toGallary imageURLString: String)
    {
        DispatchQueue.global().async {
            
            do
            {
                let data = try Data(contentsOf: URL(string: imageURLString)!)
                
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(UIImage(data: data)!, nil, nil, nil)
                    }
                    
                    self.loadingSign.stopAnimating()
                    self.loadingSign.isHidden = true
                    
                    let alertController = UIAlertController(title: imagedownloadedtitle, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
            catch
            {
                DispatchQueue.main.async {
                    self.loadingSign.stopAnimating()
                    self.loadingSign.isHidden = true
                    
                    let alertController = UIAlertController(title: imagenotfound, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func load(url: URL, to localUrl: URL, completion: @escaping () -> ())
    {
        SVProgressHUD.show(withStatus: "Downloading...")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest.init(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                
                SVProgressHUD.dismiss()
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    let lastPath  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask
                                                                        , true)[0]
                    guard let items = try? FileManager.default.contentsOfDirectory(atPath: lastPath) else { return }
                    
                    for item in items {
                        let completePath = lastPath.appending("/").appending(item)
                        try? FileManager.default.removeItem(atPath: completePath)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                    
                } catch (let writeError) {
                    print("Error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Error: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }
    
    private func open(scheme: URL) {
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(scheme, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                      completionHandler: {
                                        (success) in
                                        print("Open \(scheme): \(success)")
                                      })
        } else {
            let success = UIApplication.shared.openURL(scheme)
            print("Open \(scheme): \(success)")
        }
    }
}

extension WebViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        if (useloadingsign)
        {
            if firsthtmlrequest.isEqual("false") && (remainSplashOption) {
                loadingSign.startAnimating()
                loadingSign.isHidden = false
            }
            if (!remainSplashOption) {
                loadingSign.startAnimating()
                loadingSign.isHidden = false
            }
        }
        firsthtmlrequest = "false"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        if cssString.isEqual("")
        {
            print("No custom CSS loaded")
        }  else {
            print("Custom CSS loaded")
            let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }
        loadingSign.stopAnimating()
        loadingSign.isHidden = true
        self.webView.isHidden = false
        self.bgView.isHidden = true
        
        
        
        if (disablecallout) {
            webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        }
        if (usemystatusbarbackgroundcolor)
        {
            self.statusbarView.backgroundColor = statusbarbackgroundcolor
            view.backgroundColor = statusbarbackgroundcolor
        }
        
        isFirstTimeLoad = false
        print("Ad settings on this load: ", localCount, showFullScreenAd)
        
        if showFullScreenAd || Constants.useFacebookAds {
            localCount += 1
            
            if showadAfterX == localCount{
                
                if(Constants.useFacebookAds && Constants.useTimedAds == false){
                    //present facebook ad
                    print("Displaying a full screen FB ad")
                    self.DisplayAd()
                }
                if (showFullScreenAd){
                    //present admob ad
                    print("Displaying a full screen ad")
                    presentInterstitial()
                }
                localCount = 0
            }
        }
        webView.allowsBackForwardNavigationGestures = enableswipenavigation
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        if((error as NSError).code == NSURLErrorNotConnectedToInternet)
        {
            if(!isFirstTimeLoad)
            {
                let alertController = UIAlertController(title: offlinetitle, message: offlinemsg, preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            self.bgView.isHidden = true
            
            isFirstTimeLoad = false
            webView.isHidden = true
            loadingSign.isHidden = true
            offlineImageView.isHidden = false
            lblText1.isHidden = false
            lblText2.isHidden = false
            lblText3.isHidden = false
            btnTry.isHidden = false
            print("Test1")
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
            if (usemystatusbarbackgroundcolor)
            {
                self.statusbarView.backgroundColor = .white
                view.backgroundColor = .white
            }
            
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        
        let response = navigationResponse.response as? HTTPURLResponse
        guard let responseURL = response?.url else {
            decisionHandler(.allow)
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: response?.allHeaderFields as? [String : String] ?? [String : String](), for: responseURL)
        for cookie: HTTPCookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        
        let requestURL = navigationAction.request.url!
        
        
        if InternetConnectionManager.isConnectedToNetwork() || uselocalhtmlfolder {
            
            
            if requestURL.absoluteString.hasPrefix("fb://")
            {
                loadingSign.stopAnimating()
                self.loadingSign.isHidden = true
                UIApplication.shared.openURL(requestURL)
                decisionHandler(.cancel)
                return
                
            }
            
            //1
            if navigationAction.targetFrame == nil
            {
                self.safariWebView = SFSafariViewController(url: requestURL)
                self.present(self.safariWebView, animated: true, completion: nil)
            }
            
            if let urlScheme = requestURL.scheme {
                if urlScheme == "mailto" || urlScheme == "tel" || urlScheme == "maps" || urlScheme == "sms"{
                    if UIApplication.shared.canOpenURL(requestURL) {
                        self.open(scheme: requestURL)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
            
            //2
            if requestURL.absoluteString.hasPrefix("savethisimage://?url=")
            {
                
                let imageURL = requestURL.absoluteString.substring(from: requestURL.absoluteString.index(requestURL.absoluteString.startIndex, offsetBy: "savethisimage://?url=".count))
                debugPrint(imageURL)
                self.downloadImageAndSave(toGallary: imageURL)
                print("")
//                loadingSign.stopAnimating()
                
//                self.loadingSign.isHidden = true
                
                decisionHandler(.cancel)
                return
            }
            
            //3
            func ShareBtnAction(message: String)
            {
                print(message)
                let message1 = message.replacingOccurrences(of: "%20", with: " ", options: NSString.CompareOptions.literal, range: nil)
                let textToShare = message1
                let message = message1
                var sharingURL = ""
                if let link = NSURL(string: sharingURL)
                {
                    let objectsToShare = [message,link] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    
                    //fix for ipads as per: https://stackoverflow.com/questions/25644054/uiactivityviewcontroller-crashing-on-ios-8-ipads
                    
                    if let popoverController = activityVC.popoverPresentationController {
                        popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        popoverController.sourceView = self.view
                        popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
            
            
            if requestURL.absoluteString.prefix(11).hasPrefix("shareapp://"){
                let sharetext = requestURL.absoluteString
                let newmeg = sharetext.dropFirst(22)
                print(newmeg)
                ShareBtnAction(message: "\(newmeg)")
                decisionHandler(.cancel)
                return
                
            }
            
            
            if requestURL.absoluteString.hasPrefix("inapppurchase://"){
                if (extendediap){
                    showActions(str: "\(requestURL.absoluteString.description)")
                    decisionHandler(.cancel)
                    return
                }
                else{
                    let textiap = "UGxlYXNlIHVwZ3JhZGUgeW91ciBSZWd1bGFyIExpY2Vuc2UgdG8gYW4gRXh0ZW5kZWQgTGljZW5zZSB0byB1c2UgZmVhdHVyZXMgdGhhdCByZXF1aXJlIHlvdXIgdXNlcnMgdG8gcGF5LiBUaGlzIGlzIHJlcXVpcmVkIGJ5IHRoZSBDb2RlQ2FueW9uL0VudmF0byBNYXJrZXQgbGljZW5zZSB0ZXJtcy4gWW91IGNhbiByZXVzZSB5b3VyIGxpY2Vuc2UgZm9yIGFub3RoZXIgcHJvamVjdCBPUiByZXF1ZXN0IGEgcmVmdW5kIGlmIHlvdSB1cGdyYWRlLiBWaXNpdCB3d3cud2Vidmlld2dvbGQuY29tL3VwZ3JhZGUtbGljZW5zZSBmb3IgbW9yZSBpbmZvcm1hdGlvbi4="
                    let textiap2 = "T0s="
                    let textiap3 = "TGVhcm4gbW9yZQ=="
                    let textiap4 = "aHR0cHM6Ly93d3cud2Vidmlld2dvbGQuY29tL3VwZ3JhZGUtbGljZW5zZS8="
                    
                    let alertController = UIAlertController(title: textiap.base64Decoded(), message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: textiap2.base64Decoded(), style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    alertController.addAction(UIAlertAction(title: textiap3.base64Decoded(), style: .cancel, handler: { (action: UIAlertAction!) in
                        let url = URL (string: textiap4.base64Decoded()!)
                        self.open(scheme: url!)
                    }))
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    decisionHandler(.cancel)
                    return
                }
            }
            
            if requestURL.absoluteString.hasPrefix("inappsubscription://"){
                if (extendediap){
                    showActions(str: "\(requestURL.absoluteString.description)")
                    decisionHandler(.cancel)
                    return
                    
                }
                else{
                    let textiap = "UGxlYXNlIHVwZ3JhZGUgeW91ciBSZWd1bGFyIExpY2Vuc2UgdG8gYW4gRXh0ZW5kZWQgTGljZW5zZSB0byB1c2UgZmVhdHVyZXMgdGhhdCByZXF1aXJlIHlvdXIgdXNlcnMgdG8gcGF5LiBUaGlzIGlzIHJlcXVpcmVkIGJ5IHRoZSBDb2RlQ2FueW9uL0VudmF0byBNYXJrZXQgbGljZW5zZSB0ZXJtcy4gWW91IGNhbiByZXVzZSB5b3VyIGxpY2Vuc2UgZm9yIGFub3RoZXIgcHJvamVjdCBPUiByZXF1ZXN0IGEgcmVmdW5kIGlmIHlvdSB1cGdyYWRlLiBWaXNpdCB3d3cud2Vidmlld2dvbGQuY29tL3VwZ3JhZGUtbGljZW5zZSBmb3IgbW9yZSBpbmZvcm1hdGlvbi4="
                    let textiap2 = "T0s="
                    let textiap3 = "TGVhcm4gbW9yZQ=="
                    let textiap4 = "aHR0cHM6Ly93d3cud2Vidmlld2dvbGQuY29tL3VwZ3JhZGUtbGljZW5zZS8="
                    
                    let alertController = UIAlertController(title: textiap.base64Decoded(), message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: textiap2.base64Decoded(), style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    alertController.addAction(UIAlertAction(title: textiap3.base64Decoded(), style: .cancel, handler: { (action: UIAlertAction!) in
                        let url = URL (string: textiap4.base64Decoded()!)
                        self.open(scheme: url!)
                    }))
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    decisionHandler(.cancel)
                    return
                }
            }
            
            if requestURL.absoluteString.hasPrefix("get-uuid://"){
                let uuidString = "var uuid = \"\(Constants.kDeviceId)\";"
                print("UUID:")
                print(uuidString)
                webView.evaluateJavaScript(uuidString, completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
            //API TO GET STATUS
            
            if requestURL.absoluteString.hasPrefix("user-disable-tracking://")
            {
                var trackingString = "var trackingDisabled = \"false\";"
                
                if #available(iOS 14, *) {
                    print("Checking tracking status", ATTrackingManager.trackingAuthorizationStatus.rawValue)
                    if(ATTrackingManager.trackingAuthorizationStatus.rawValue == 2){
                        trackingString = "var trackingDisabled = \"true\";"
                    }
                }
                print(trackingString)
                webView.evaluateJavaScript(trackingString, completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
            
       
            if requestURL.absoluteString.hasPrefix("spinneron://")
            {
                loadingSign.isHidden = false
                decisionHandler(.cancel)
                loadingSign.startAnimating()
                return
            }
            
            
            if requestURL.absoluteString.hasPrefix("spinneroff://")
            {
                loadingSign.isHidden = true
                decisionHandler(.cancel)
                print("Spinner off!")
                return
            }
            
            if requestURL.absoluteString.hasPrefix("screenshot://")
            {
                print("Screenshot!")
                
                let layer = UIApplication.shared.keyWindow!.layer
                let scale = UIScreen.main.scale
                // Creates UIImage of same size as view
                UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                layer.render(in: UIGraphicsGetCurrentContext()!)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                // THIS IS TO SAVE SCREENSHOT TO PHOTOS
                UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
                
                let alert = UIAlertController(title: "Screenshot Succesful", message: "", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                decisionHandler(.cancel)

                return
            }
            
            
            if requestURL.absoluteString.hasPrefix("registerpush://")
            {
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    print("User accepted notifications: \(accepted)")
                })
                
                if #available(iOS 10.0, *)
                {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {(accepted, error) in
                        if !accepted {
                            print("Notification access denied")
                        }
                    }
                }
                else
                {
                    
                }
                
                decisionHandler(.cancel)
                
                return
            }
            
            
            if requestURL.absoluteString.hasPrefix("reset://")
            {
                URLCache.shared.removeAllCachedResponses()
                URLCache.shared.removeAllCachedResponses()
                let config = WKWebViewConfiguration()
                config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                config.allowsInlineMediaPlayback = true
                config.mediaTypesRequiringUserActionForPlayback = []
                HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
                
                let webView = WKWebView(frame: .zero, configuration: config)
                let alert = UIAlertController(title: "App reset was successful", message: "Thank you.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                webView.reload()
                decisionHandler(.cancel)
                return
                
            }
            
            
            if ((requestURL.host != nil) && requestURL.host! == "push.send.cancel")
            {
                UIApplication.shared.cancelAllLocalNotifications()
                
                decisionHandler(.cancel)
                return
            }
            
            
            if ((requestURL.host != nil) && requestURL.host! == "push.send")
            {
                let prerequest = requestURL
                let finished = prerequest.absoluteString
                var requested = finished.components(separatedBy: "=")
                let seconds = requested[1]
                var logindetails = finished.components(separatedBy: "msg!")
                let logindetected = logindetails[1]
                var logindetailsmore = logindetected.components(separatedBy: "&!#")
                let msg0 = logindetailsmore[0]
                let button0 = logindetailsmore[1]
                let msg = msg0.replacingOccurrences(of: "%20", with: " ")
                let button = button0.replacingOccurrences(of: "%20", with: " ")
                let sendafterseconds: Double = Double(seconds)!
                
                if #available(iOS 10.0, *)
                {
                    let action = UNNotificationAction(identifier: "buttonAction", title: button, options: [])
                    let category = UNNotificationCategory(identifier: "localNotificationTest", actions: [action], intentIdentifiers: [], options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.body = msg
                    notificationContent.sound = UNNotificationSound.default
                    
                    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: sendafterseconds, repeats: false)
                    
                    let localNotificationRequest = UNNotificationRequest(identifier: "localNotificationTest", content: notificationContent, trigger: notificationTrigger)
                    
                    UNUserNotificationCenter.current().add(localNotificationRequest) {(error) in
                        if let error = error {
                            print("We had an error: \(error)")
                        }
                    }
                }
                else
                {
                    let pushmsg1 = UILocalNotification()
                    pushmsg1.fireDate = Date().addingTimeInterval(sendafterseconds)
                    pushmsg1.timeZone = NSTimeZone.default
                    pushmsg1.alertBody = msg
                    pushmsg1.soundName = UILocalNotificationDefaultSoundName
                    pushmsg1.alertAction = button
                    UIApplication.shared.scheduleLocalNotification(pushmsg1)
                }
                
                decisionHandler(.cancel)
                return
            }
    
            
            if ((requestURL.host != nil) && requestURL.absoluteString.contains(".ics"))
            {
                
                self.safariWebView = SFSafariViewController(url: requestURL)
                self.present(self.safariWebView, animated: true, completion: nil)
                
                decisionHandler(.cancel)
                return
            }
            
            if ((requestURL.host != nil) && requestURL.absoluteString.contains("whatsapp.com"))
            {
                loadingSign.stopAnimating()
                self.loadingSign.isHidden = true
                UIApplication.shared.openURL(requestURL)
                decisionHandler(.cancel)
                return
            }
            
            
            func qrOnComplete(){
                loadingSign.isHidden = true;
            }
            
            func qrbuttonaction()
            {
                let scanner = QRCodeScannerController()
                //let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), cancelImage: UIImage(named: "cancel"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
                 scanner.delegate = self
                scanner.modalPresentationStyle = .fullScreen
                self.present(scanner, animated: true, completion: qrOnComplete)
            }
            
            if requestURL.absoluteString.hasPrefix("qrcode://"){
                print("print")
                qrbuttonaction()
                decisionHandler(.cancel)
                return
                
            }

            
            if (uselocalhtmlfolder) {
                if (requestURL.scheme! == "http") || (requestURL.scheme! == "https") || (requestURL.scheme! == "mailto") && (navigationAction.navigationType == .linkActivated)
                {
                    if (openallexternalurlsinsafaribydefault && !deeplinkingrequest) {
                        deeplinkingrequest = false
                        self.open(scheme: requestURL)
                        
                        decisionHandler(.cancel)
                        return
                    }
                }
                else
                {
                    decisionHandler(.allow)
                    return
                }
            }
        
            
            let internalFileExtension = (requestURL.absoluteString as NSString).lastPathComponent
            let extstr = "\(internalFileExtension.fileExtension())"
            print(extstr)
            
            print("ext:", extstr, extstr == "")
            
            //if we have a download request with extension that matches our download list
            if(extstr != "" && Constants.extentionARY.contains(extstr)){
        
                    var localURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask
                                                                       , true)[0]
                    localURL = localURL + "/Download." + internalFileExtension
                    let strURL = (requestURL.absoluteString as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue)
                    
                    DispatchQueue.main.async {
                        
                        guard let url = strURL?.makeURL() else{
                            return
                        }
                        
                        self.load(url: url, to: URL.init(fileURLWithPath: localURL), completion: {
                            
                            let objectsToShare =  NSURL.init(fileURLWithPath: localURL)
                            let activityVC = UIActivityViewController(activityItems: [objectsToShare], applicationActivities: nil)
                            
                            if UIDevice.current.userInterfaceIdiom == .pad
                            {
                                activityVC.popoverPresentationController?.sourceView = self.view
                                let popover = UIPopoverController(contentViewController: activityVC)
                                DispatchQueue.main.async {
                                    popover.present(from:  CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0), in: self.view, permittedArrowDirections: .any, animated: true)
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async {
                                    self.present(activityVC, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                    decisionHandler(.cancel)
                    return
            }
            
            
            
            //OPENING IN SAFARI LOGIC
            
            // if it is in the whitelist and not in blacklist open in safari
            // or if openallexternalurls is enabled and its not in blacklist
            if (requestURL.host != nil) && (( safariwhitelist.contains(requestURL.host!)) || (openallexternalurlsinsafaribydefault && (navigationAction.navigationType == .linkActivated)
            && !safariblacklist.contains(requestURL.host!)))
            {
                loadingSign.stopAnimating()
                self.loadingSign.isHidden = true
                UIApplication.shared.open(requestURL)
                decisionHandler(.cancel)
                return
            }
            
        }
        
        else{
            
            if Constants.offlinelocalhtmlswitch == true {
                if (offlineswitchcount < 2){
                    usemystatusbarbackgroundcolor = false
                    statusbarbackgroundcolor = first_statusbarbackgroundcolor
                    statusbarView.backgroundColor = statusbarbackgroundcolor
                    decisionHandler(.cancel)
                    bgView.isHidden = true
                    statusbarView.isHidden = false
                    webView.stopLoading()
                    let url = Bundle.main.url(forResource: "index", withExtension:"html")
                    webView.load(URLRequest(url: url!))
                    offlineswitchcount = 2
                    return
                    
                }
                else {
                    offlineswitchcount = 1
                    decisionHandler(.allow)
                    return
                }
                
            } else{
                offlineImageView.isHidden = false
                webView.isHidden = true
                bgView.isHidden = true
                lblText1.isHidden = false
                lblText2.isHidden = false
                lblText3.isHidden = false
                btnTry.isHidden = false
                loadingSign.isHidden = true
                print("Test2")
                
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
                if (usemystatusbarbackgroundcolor)
                {
                    self.statusbarView.backgroundColor = .white
                    view.backgroundColor = .white
                }
            }
            decisionHandler(.cancel)
            return
        }
        
        
        decisionHandler(.allow)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func loadHtmlFile() {
        if #available(iOS 13.0, *) {
            let vc = self.storyboard?.instantiateViewController(identifier: "LoadindexpageVC") as! LoadindexpageVC
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadindexpageVC") as! LoadindexpageVC
            self.present(vc, animated: true, completion: nil)
        }
        
        
    }
    
}
extension WebViewController: QRScannerCodeDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print("result:\(result)")
        loadingSign.isHidden = true
        if verifyUrl(urlString: "\(result)") == true {
            
            if (qrcodelinks == "0"){ //Open QR Code links in the Main WebView window
                let url = URL (string: result)
                let requestObj = URLRequest(url: url!)
                webView.load(requestObj)
            }
            
            if (qrcodelinks == "1"){ //Open QR Code links in a new popup
                let urlqr = URL (string: result)
                self.safariWebView = SFSafariViewController(url: urlqr!)
                self.present(self.safariWebView, animated: true, completion: nil)
            }
            if (qrcodelinks == "2"){ //Open QR Code links in the Safari Browser
                let url = URL (string: result)
                self.open(scheme: url!)
            }
            
        }
        
    }
    
    func qrCodeScanningFailedWithError(error: String) {
        
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
   
        
        
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        print("error:\(error)")
    }
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
        loadingSign.isHidden = true
        //return
    }
}

extension WebViewController
{
    
    
    private func addWebViewToMainView(_ webView: WKWebView)
    {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        print(UIScreen.main.nativeBounds.height)
        switch UIScreen.main.nativeBounds.height {
        
        case 1624:
            
            view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 25))
            if showBannerAd {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -66))
            }else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))
                
            }
        case 2436,2688,1792:
            if (bigstatusbar)
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 45))
            }
            else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 32))
            }
            if showBannerAd {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -66))
            }else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))
                
            }
        case 1334,2208:
            if (bigstatusbar)
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 35))
            }
            else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 25))
            }
            if showBannerAd
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -44))
                
            }
            else
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))
            }
            
        default:
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                if (bigstatusbar)
                {
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 40))
                }else{
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 35))
                }
            case .unspecified:
                break
            case .pad:
                if (bigstatusbar)
                {
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 40))
                }else{
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 22))
                }
                
            case .tv:
                break
            case .carPlay:
                break
            case .mac:
                break
            @unknown default:
                break
            }
            
            if showBannerAd
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -44))
                
            }
            else
            {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))
            }
        }
        
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: view , attribute: .right, multiplier: 1, constant:0))
        view.layoutIfNeeded()
        webView.isHidden = true
        self.view.bringSubviewToFront(bannerView)
    }
}

extension WebViewController: WKUIDelegate
{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let urllocal = navigationAction.request.url
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        self.safariWebView = SFSafariViewController(url: urllocal!)
        self.present(self.safariWebView, animated: true, completion: nil)
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            completionHandler()
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
            textField.placeholder = "Enter here..."
        }
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
        ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
}


fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}


fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


extension WebViewController {
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please test on real devices (no simulators) or contact support."
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: "Unknown error. Please test on real devices (no simulators) or contact support.")
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: "Unknown error. Please test on real devices (no simulators) or contact support.")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please test on real devices (no simulators) or contact support.")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("\(productId) is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("\(productId) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func DisplayAd(){
            self.interstitialAd = FBInterstitialAd(placementID: fbInterstitialAdID)
            self.interstitialAd.delegate = self
            self.interstitialAd.load()
    }
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        self.interstitialAd.show(fromRootViewController: self)
//        timer1?.invalidate()
    }
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        print("Ads close")
        activeFBAd = false;
//        timer1?.fire()
    }
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("ads error, ")
        print(error)
//        timer1?.vali
        
    }
}
