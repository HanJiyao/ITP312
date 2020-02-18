import UIKit
import SafariServices
import Photos
import MapKit
import JJFloatingActionButton
import FlagKit
import Firebase

protocol FolderDelegate: NSObjectProtocol {
    func passFolderID(data: String)
}

class ViewController: UIViewController {
    
    weak var folderDelegate: FolderDelegate?

    // MARK: UI Metrics
    
    struct UI {
        static let itemHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 88 : 65
        static let lineSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20
        static let xInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20
        static let topInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 40 : 28
    }
    
    // MARK: Properties
    
    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.register(TypeOneCell.self, forCellWithReuseIdentifier: TypeOneCell.identifier)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollView.DecelerationRate.fast
        //$0.contentInsetAdjustmentBehavior = .never
        $0.bounces = true
        $0.backgroundColor = .white
        //$0.maskToBounds = false
        //$0.clipsToBounds = false
        $0.contentInset.bottom = UI.itemHeight
        return $0
        }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    fileprivate lazy var layout: VerticalScrollFlowLayout = {
        $0.minimumLineSpacing = UI.lineSpacing
        $0.sectionInset = UIEdgeInsets(top: UI.topInset, left: 0, bottom: 0, right: 0)
        $0.itemSize = itemSize
        
        return $0
    }(VerticalScrollFlowLayout())
    
    fileprivate var itemSize: CGSize {
        let width = UIScreen.main.bounds.width - 2 * UI.xInset
        return CGSize(width: width, height: UI.itemHeight)
    }
    
    // MARK: Initialize
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
//        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        print("no init")
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: ViewController LifeCycle
    
    override func loadView() {
        view = collectionView
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate let actionButton = JJFloatingActionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        title = "Gallery"

        //let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        //add.tintColor = .blue
        //self.navigationItem.rightBarButtonItem = add
        
        //navigationController?.navigationBar.backgroundColor = .white
        //navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false //scroll back to top title from middle goes back to largetitle
        //navigationController?.navigationBar.shadowImage = UIImage()

        layout.itemSize = itemSize
        collectionView.collectionViewLayout.invalidateLayout()

        configureActionButton()
     
        loadFolder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            let navBarAppearance = UINavigationBarAppearance()
            
            navBarAppearance.configureWithOpaqueBackground() //needed to make bar white
            //            navBarAppearance.backgroundColor = .init(red: 95, green: 201, blue: 248)
            navigationController?.view.backgroundColor = .white //https://blog.kulman.sk/fixing-black-artifact-changing-large-tiles-mode/
            navBarAppearance.shadowColor = nil //remove line below title
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
        }
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func configureActionButton() {
        //        actionButton.itemAnimationConfiguration = .slideIn(withInterItemSpacing: 14)
        
        let firstItem = actionButton.addItem()
        firstItem.titleLabel.text = "Create custom folder"
        firstItem.imageView.image = UIImage(systemName: "folder")
        firstItem.buttonColor = .white
        firstItem.buttonImageColor = UIColor(hex: 0x007AFF)
        
        firstItem.action = { item in
            print("selected create custom folder", item)
            let alert = UIAlertController(style: .actionSheet, title: "Please enter folder name", message: "you can give it any name!")
            var textRetrieved: String = ""
            let textField: TextField.Config = { textField in
                textField.left(image: #imageLiteral(resourceName: "pen"), color: .black)
                textField.leftViewPadding = 12
                textField.becomeFirstResponder()
                textField.borderWidth = 1
                textField.cornerRadius = 8
                textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                textField.backgroundColor = nil
                textField.textColor = .black
                textField.placeholder = "Type something"
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                //textField.isSecureTextEntry = true
                textField.returnKeyType = .done
                textField.action { textField in
//                    Log("textField = \(String(describing: textField.text))")
                    textRetrieved = textField.text!
                }
            }
            alert.addOneTextField(configuration: textField)
            alert.addAction(title: "OK", style: .cancel, handler: { result in
                print("ok clicked", textRetrieved)
                if textRetrieved != "" {
                    self.createFolder(title: textRetrieved, subtitle: "0")
                } else {
                    let alertController = UIAlertController(title: "Oops!", message: "Folder name cannot be empty!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Noted!", style: .default)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            alert.show()
        }
        
        let secondItem = actionButton.addItem()
        secondItem.titleLabel.text = "Create country folder"
        secondItem.imageView.image = UIImage(systemName: "flag")
        secondItem.buttonColor = .white
        secondItem.buttonImageColor = UIColor(hex: 0x007AFF)
        secondItem.imageSize = CGSize(width: 28, height: 28)
        
        secondItem.action = { item in
            let alert = UIAlertController(style: .actionSheet, title: "Select Country")
            alert.addLocalePicker(type: .country) { info in
                self.createCountry(countryCode: info!.code, countryName: info!.country)
            }
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }
        
        actionButton.itemAnimationConfiguration = .circularSlideIn(withRadius: 60)
        actionButton.buttonAnimationConfiguration = .rotation(toAngle: .pi * 3 / 4)
        actionButton.buttonAnimationConfiguration.opening.duration = 0.8
        actionButton.buttonAnimationConfiguration.closing.duration = 0.6
        actionButton.buttonImage = UIImage(systemName: "pencil")
        actionButton.buttonImageSize = CGSize(width: 30, height: 30)
        actionButton.buttonAnimationConfiguration = .transition(toImage: UIImage(systemName: "xmark")!)
        
        actionButton.buttonColor = .systemBlue
        
        view.addSubview(actionButton)
//        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        actionButton.display(inViewController: self)
    }
    
     func showAlert(for item: JJActionItem) {
        showAlert(title: item.titleLabel.text, message: "Item tapped!")
    }

     func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    var folderList:[FolderModel] = []


    /*@objc func addTapped() {
        print("add tapped")
    }
    */
    
    func createCountry(countryCode: String, countryName: String) {
        //let flag = Flag(countryCode: countryCode)!
        //let originalImage = flag.originalImage
        createFolder(title: countryName, subtitle: "0", countryCode: countryCode)
    }
    
    func createFolder(title: String, subtitle: String, countryCode: String? = nil) {
        let oneFolder = DataManager.createFolder(title: title, subtitle: subtitle, countryCode: countryCode)
        DataManager.showToast(message: "New folder created!", sender: self)
        self.folderList.append(oneFolder)
    }
    
    func loadFolder() { //fix all in scope shortcut key = ctrl + opt + cmd + f
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        ref.child("folder").child(currentUser).queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            self.folderList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                print("child key", child.key)
//                let photoCount = child.childSnapshot(forPath: "photo").childrenCount
//                ref.child("folder").child(currentUser).child(child.key).updateChildValues(["subtitle": photoCount])
                let oneFolder = FolderModel(data: child.value as! [String : Any])
//                let image = oneFolder.image = "listings" ? UIImage(named: "listings") : UIImage(Flag(countryCode: "\(oneFolder.image)")?.originalImage)
//                print("photo count", photoCount)
//                oneFolder.subtitle = "\(photoCount)"
                self.folderList.append(oneFolder)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
}

// MARK: - CollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = folderDelegate {
            print("let delegate...")
            delegate.passFolderID(data: folderList[indexPath.row].key!)
            self.dismiss(animated: true, completion: nil)
            return
        }
//        Log("selected alert - \(alerts[indexPath.item].rawValue)")
//        show(alert: alerts[indexPath.item])
        let storyboard = UIStoryboard(name: "GalleryStoryboard", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoView") as! PhotoViewController
//        present(photoViewController, animated: true, completion: nil)
        photoViewController.folderObject = folderList[indexPath.row]
        navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    func hideActionButton() {
        actionButton.isHidden = true
    }
}

// MARK: - CollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: TypeOneCell.identifier, for: indexPath) as? TypeOneCell else { return UICollectionViewCell() }
        
        let folder = folderList[indexPath.item]
        
        if folder.image == "listings" {
            item.imageView.image = UIImage(named: "listings")
            item.imageView.tintColor = UIColor.init(hexString: folder.color!) //change folder color using the hex?
        } else {
            let flag = Flag(countryCode: folder.image!)
            item.imageView.image = flag?.originalImage
        }
        
        item.title.text = folder.title
        item.subtitle.text = folder.subtitle
        item.subtitle.textColor = .darkGray
        
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = folderList.remove(at: sourceIndexPath.item)
        folderList.insert(temp, at: destinationIndexPath.item)
        //https://nshint.github.io/blog/2015/07/16/uicollectionviews-now-have-easy-reordering/
                print("Starting Index: \(sourceIndexPath.item)")
                print("Ending Index: \(destinationIndexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
            
            let thisFolder = self.folderList[indexPath.row]
            
            //thisFolder.printObj("this folder")
            
            let colorMenu = UIAction(title: "Customize folder color", image: UIImage(named: "colors")) { _ in
                print("color menu clicked..")
                let alert = UIAlertController(style: .actionSheet)
                alert.addColorPicker(color: UIColor(hexString: thisFolder.color!)) { color in
                    //Log(color)
                    DataManager.ref().child("folder").child(DataManager.currentUser()).child(thisFolder.key!).updateChildValues(["color": color.hexString])
                    DataManager.showToast(message: "Color of folder updated!", sender: self)
                }
                alert.addAction(title: "Cancel", style: .cancel)
                alert.show()
            }
            
            let deleteMenu = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                print("delete menu clicked.")
                DataManager.ref().child("folder").child(DataManager.currentUser()).child(thisFolder.key!).removeValue()
                DataManager.showToast(message: "Folder deleted!", sender: self)
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, children: thisFolder.image == "listings" ? [colorMenu, deleteMenu] : [deleteMenu])
            
        }
        return configuration
    }
    
}
