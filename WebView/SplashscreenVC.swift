//  OnlineAppCreator.com
//  WebViewGold for iOS // webviewgold.com

/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */

import UIKit

class SplashscreenVC: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    var gameTimer: Timer?
    @IBOutlet var mainbackview: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.splshscreencolor
        let jeremyGif = UIImage.gifImageWithName("splash")
        imageview.image = jeremyGif
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)

    }
    @objc func fireTimer() {
        print("Timer fired!")
        if #available(iOS 13.0, *) {
            let ncv = self.storyboard?.instantiateViewController(identifier: "homenavigation") as! UINavigationController
            self.present(ncv, animated: false, completion: nil)
        } else {
            // Fallback on earlier versions
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homenavigation") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }
        
    }

}
