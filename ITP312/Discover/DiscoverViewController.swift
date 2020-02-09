import UIKit
import SafariServices
import Photos

class DiscoverViewController: UIViewController {
    
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        let alert = UIAlertController(style: .actionSheet, message: "Select Country")
//        alert.addLocalePicker(type: .country) { info in
//            // action with selected object
//            dump(info)
//        }
//        alert.addAction(title: "OK", style: .cancel)
//        alert.show()
//        window = UIWindow(frame: UIScreen.main.bounds)
//            window?.rootViewController = UINavigationController(rootViewController: ViewController())
//            window?.makeKeyAndVisible()
//        let storyBoard = UIStoryboard(name: "DiscoverStoryboard", bundle: nil) as UIStoryboard
//        let loginViewController = ViewController()
////        window.contentViewController = loginViewController
//        window?.rootViewController = loginViewController
        
//    let alert = UIAlertController(style: .actionSheet, title: "Currencies")
//        alert.addLocalePicker(type: .currency) { info in
//            alert.title = info?.currencyCode
//            alert.message = "is selected"
//            // action with selected object
//        }
//        alert.addAction(title: "OK", style: .cancel)
//        alert.show()
        
//        let chatLogViewController = self.storyboard.instantiateViewController(identifier: "ChatLog") as! ChatLogViewController
//            present(ViewController(), animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    
}
