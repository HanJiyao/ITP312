//
//  SwipePhotoViewController.swift
//  ITP312
//
//  Created by tyr on 16/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Shuffle_iOS
import PopBounceButton
import Firebase
import FlagKit
import Loaf

class SwipePhotoViewController: UIViewController, FolderDelegate, ChatDelegate {
   
    var countrySelectedList: [String] = []
    
    var cardList: [CardModel] = []
    
    var allCardsSwiped = false
    
    var currentCardIndex = 0
    var triggerSwipeUp = false
    var triggerSwipeDown = false
    var triggerSwipeRight = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Photos"
        loadCountriesPhotos()
        addRightNavigationBar()
        
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
                
        layoutButtonStackView()
        layoutCardStackView()
        configureBackgroundGradient()
        
        print("viewdidload..", triggerSwipeUp)
    }
    
    func addRightNavigationBar() {
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(moreBtnClicked))
        navigationItem.rightBarButtonItem = forwardButton
    }

    
    func loadCountriesPhotos() {
        let ref = DataManager.ref()
        let group = DispatchGroup()
        for country in countrySelectedList {
            group.enter()
            ref.child("country").child(country).observeSingleEvent(of: .value) { snapshot in
                self.loopCountrySnapshot(snapshot)
                group.leave()
            }
        }
        print("card list...", self.cardList.count) //synchronous
        group.notify(queue: .main) { //https://stackoverflow.com/questions/42614171/how-to-reload-data-after-all-firebase-calls-finished
            print("All callbacks are completed", self.cardList.count)
            if self.cardList.count == 0 { self.loadAllCountriesPhotos() }
            else {
                DispatchQueue.main.async {
                    self.cardStack.reloadData()
                }
            }
        }
    }
    
    func loopCountrySnapshot(_ snapshot: DataSnapshot) {
        for case let child as DataSnapshot in snapshot.children {
            let oneCard = CardModel(data: child.value as! [String : Any])
            self.cardList.append(oneCard)
        }
    }
    
       
    func loadAllCountriesPhotos() {
        let ref = DataManager.ref()
        ref.child("country").observe(.value) { (snapshot) in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String: Any] else {return}
//                print("child key", child.key)
//                print(dict)
//                print(dict.values)
//                print(dict.keys)
                for key in dict.keys {
                    let value = child.childSnapshot(forPath: key).value
                    let oneCard = CardModel(data: value as! [String : Any])
                    self.cardList.append(oneCard)
                }
            }
            print("card list...", self.cardList.count)
            DispatchQueue.main.async {
                self.cardStack.reloadData()
            }
        }
    }
        
    
    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()
    
    
    private func configureBackgroundGradient() {
        let backgroundGray = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
    }
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: buttonStackView.topAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    @objc private func handleShift(_ sender: UIButton) {
        cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
        print("handle backed")
    }
    
    @objc func moreBtnClicked() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Select one of the following", font: .systemFont(ofSize: 20), color: .black)
        alert.addAction(image: UIImage(systemName: "icloud.and.arrow.down"), title: "Download photo", color: .blue, handler: { _ in
            self.triggerSwipeDown = true
            self.downloadPhoto()
        })
        alert.addAction(image: UIImage(systemName: "folder.badge.plus"), title: "Choose a folder to save photo", color: .blue, handler: chooseFolder)
        alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
        alert.show(animated: true, vibrate: true)
    }
    
    func downloadPhoto() {
        print("downloading photo")
        if !allCardsSwiped {
            let imageCreated = DataManager.createUIImageFromURL(imageURL: cardList[cardStack.topCardIndex].imageURL!)
            UIImageWriteToSavedPhotosAlbum(imageCreated, self, #selector(imageDownloaded), nil)
        }
    }
    
    @objc func imageDownloaded(image:UIImage,didFinishSavingWithError error:Error?,contextInfo:UnsafeMutableRawPointer?) {
        if error != nil {return}
        print("successfully downloaded image")
        DataManager.showToast(message: "Successfully downloaded to your photo album!", sender: self)
        if triggerSwipeDown {
            cardStack.swipe(.down, animated: true)
        }
    }
    
    func chooseFolder(_ alertAction: UIAlertAction) {
        let viewController = DataManager.viewControllerFromStoryboard(name: "DiscoverStoryboard", identifier: "Folder") as! ViewController
        viewController.folderDelegate = self
        viewController.hideActionButton()
        self.present(viewController, animated: true, completion: nil)
    }
    
    func passFolderID(data: String) {
        print("received data folder id key!!!", data)
        if !allCardsSwiped {
            
            let ref = DataManager.ref()
            let currentUser = DataManager.currentUser()
            let currentCard = cardList[cardStack.topCardIndex]
            
            guard let key = ref.child("folder").child(currentUser).child(data).child("photo").childByAutoId().key else {return}
        
            let values = [
                "imageURL": currentCard.imageURL!,
                "name": currentCard.name!,
                "country": currentCard.country!,
                "timestamp": ServerValue.timestamp(),
                "key": key
                ] as [String : Any]
//            print(values)
            
            ref.child("folder").child(currentUser).child(data).child("photo").child(key).setValue(values)
    
            DataManager.updateFolderPhotoCount(folderIDToUploadPhoto: data)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                DataManager.showToast(message: "Saved to folder (\(data))", sender: self)
            }
            
            triggerSwipeRight = true
            cardStack.swipe(.right, animated: true)
            
        }
    }
    
}




//MARK: Data Source + Delegates

extension SwipePhotoViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SampleCard()
//        card.configure(withModel: cardModels[index])
        card.configureFB(withModel: cardList[index])
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
//        return cardModels.count
//        print("card list", cardList.count)
        return cardList.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
        allCardsSwiped = true
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        //print("Undo \(direction) swipe on \(cardList[index].name)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        //print("Swiped \(direction) on \(cardList[index].name)")
        currentCardIndex = index
        if direction == .up {
            triggerSwipeUp
                ? triggerSwipeUp = false
                : shareToChat()
        }
        else if direction == .right {
            triggerSwipeRight
                ? triggerSwipeRight = false
                : saveToGallery()
        }
        else if direction == .down {
            triggerSwipeDown
                ? triggerSwipeDown = false
                : downloadPhoto()
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
    }
        
    func didTapButton(button: TinderButton) {
        currentCardIndex = cardStack.topCardIndex
        switch button.tag {
        case 1:
            cardStack.undoLastSwipe(animated: true)
        case 2:
            cardStack.swipe(.left, animated: true)
        case 3: //chat, download, create plan, save to folder
            //cardStack.swipe(.up, animated: true)
            triggerSwipeUp = true
            shareToChat()
        case 4:
            //cardStack.swipe(.right, animated: true)
            triggerSwipeRight = true
            saveToGallery()
        case 5:
            triggerSwipeRight = true
            lastButtonCreatedPlan()
        default:
            break
        }
    }
    
    func shareToChat() {
        print("sharing to chat")
        let viewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "Chat") as! ChatMainViewController
        viewController.chatDelegate = self
        present(viewController, animated: true, completion: nil) //delegate will callback passChatUser
    }
    
    func passChatUser(user: User) {
        //user.printObj("sharing to this user...")
        
        let imageCreated = DataManager.createUIImageFromURL(imageURL: cardList[currentCardIndex].imageURL!)
        
        let chatLogViewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
                           
        if triggerSwipeUp {
            cardStack.swipe(.up, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                DataManager.uploadImageToChat(image: imageCreated, toID: user.id)
                self.navigationController?.pushViewController(chatLogViewController, animated: true)
            }
        } else {
            DataManager.uploadImageToChat(image: imageCreated, toID: user.id)
            navigationController?.pushViewController(chatLogViewController, animated: true)
        }
                
    }
    
    func saveToGallery() {
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        let currentCard = cardList[currentCardIndex]
        let folderID = currentCard.country!
        ref.child("folder").child(currentUser).child(currentCard.country!).observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                print("country folder does not exist!!!")
                let countryCodeGenerated = Locale(identifier: "en_US_POSIX").isoCode(for: currentCard.country!)!
                DataManager.createFolder(title: currentCard.country!, subtitle: "0", countryCode: countryCodeGenerated)
            }
            guard let key = ref.child("folder").child(currentUser).child(folderID).child("photo").childByAutoId().key else { return }
            let values = [
                "imageURL": currentCard.imageURL!,
                "name": currentCard.name!,
                "country": currentCard.country!,
                "timestamp": ServerValue.timestamp(),
                "key": key
                ] as [String : Any]
            ref.child("folder").child(currentUser).child(folderID).child("photo").child(key).setValue(values) { (err, ref) in
                if err != nil {return}
                
                DataManager.updateFolderPhotoCount(folderIDToUploadPhoto: folderID)
                
                DataManager.showToast(message: "Saved to folder (\(currentCard.country!))", sender: self)
                
                if self.triggerSwipeRight {
                    self.cardStack.swipe(.right, animated: true)
                }
            }
        }
    }
    
    func lastButtonCreatedPlan() {
         print("last button tapped creating plan...", currentCardIndex)
         cardStack.swipe(.right, animated: true)
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            let planViewController = DataManager.viewControllerFromStoryboard(name: "Plans", identifier: "SetDateStoryboardID") as! SetDateForPlanViewController
            planViewController.countryName = self.cardList[self.currentCardIndex].country
            self.navigationController?.pushViewController(planViewController, animated: true)
         }
     }

    
}

