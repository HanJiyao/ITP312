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

class SwipePhotoViewController: UIViewController, FolderDelegate, ChatDelegate {
   
    var countrySelectedList: [String] = []
    
    var cardList: [CardModel] = []
    
    var allCardsSwiped = false
    
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
    
    private let cardModels = [
        SampleCardModel(name: "Michelle",
                        age: 26,
                        occupation: "Graphic Designer",
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Joshua",
                        age: 27,
                        occupation: "Business Services Sales Representative",
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Daiane",
                        age: 23,
                        occupation: "Graduate Student",
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Julian",
                        age: 25,
                        occupation: "Model/Photographer",
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Andrew",
                        age: 26,
                        occupation: nil,
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Bailey",
                        age: 25,
                        occupation: "Software Engineer",
                        image: UIImage(named: "mexico")),
        SampleCardModel(name: "Rachel",
                        age: 27,
                        occupation: "Interior Designer",
                        image: UIImage(named: "mexico"))
    ]
    
    
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
        alert.addAction(image: UIImage(systemName: "icloud.and.arrow.down"), title: "Download photo", color: .blue, handler: downloadPhoto)
        alert.addAction(image: UIImage(systemName: "folder.badge.plus"), title: "Choose a folder to save photo", color: .blue, handler: chooseFolder)
        alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
        alert.show(animated: true, vibrate: true)
    }
    
    func downloadPhoto(_ alertAction: UIAlertAction) {
        print("downloading photo")
        if !allCardsSwiped {
            UIImageWriteToSavedPhotosAlbum(cardModels[cardStack.topCardIndex].image!, self, #selector(imageDownloaded), nil)
        }
    }
    
    @objc func imageDownloaded(image:UIImage,didFinishSavingWithError error:Error?,contextInfo:UnsafeMutableRawPointer?) {
        if error != nil {return}
        print("successfully downloaded image")
    }
    
    func chooseFolder(_ alertAction: UIAlertAction) {
        let viewController = DataManager.viewControllerFromStoryboard(name: "DiscoverStoryboard", identifier: "Folder") as! ViewController
        viewController.folderDelegate = self
        viewController.hideActionButton()
        present(viewController, animated: true, completion: nil)
    }
    
    func passFolderID(data: String) {
        print("received data folder id key!!!", data)
        if !allCardsSwiped {
            let ref = DataManager.ref()
            let currentUser = DataManager.currentUser()
            let currentCard = cardList[cardStack.topCardIndex]
            let values = [
                "imageURL": currentCard.imageURL!,
                "name": currentCard.name!,
                "country": currentCard.country!,
                "timestamp": ServerValue.timestamp()
                ] as [String : Any]
            print(values)
            ref.child("folder").child(currentUser).child(data).child("photo").childByAutoId().setValue(values)
    
            DataManager.updateFolderPhotoCount(folderIDToUploadPhoto: data)
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
        print("card list", cardList.count)
        return cardList.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
        allCardsSwiped = true
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cardList[index].name)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(cardList[index].name)")
        let currentCard = cardList[index]
        if direction == .up {
            shareToChat()
        }
        else if direction == .right {
            saveToGallery(currentCard)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
    }
    
    func didTapButton(button: TinderButton) {
        switch button.tag {
        case 1:
            cardStack.undoLastSwipe(animated: true)
        case 2:
            cardStack.swipe(.left, animated: true)
        case 3: //chat, download, create plan, save to folder
            cardStack.swipe(.up, animated: true)
            shareToChat()
        case 4:
            cardStack.swipe(.right, animated: true)
        case 5:
            lastButtonCreatedPlan()
        default:
            break
        }
    }
    
    func lastButtonCreatedPlan() {
        print("last button tapped")
//        let planViewController = DataManager.viewControllerFromStoryboard(name: "Plans", identifier: "")
    }
    
    func shareToChat() {
        print("sharing to chat")
        let viewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "Chat") as! ChatMainViewController
        viewController.chatDelegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func passChatUser(user: User) {
        user.printObj("sharing to this user...")
        
        let imageCreated = DataManager.createUIImageFromURL(imageURL: cardList[cardStack.topCardIndex].imageURL!)
        
        DataManager.uploadImageToChat(image: imageCreated, toID: user.id)
        
        let chatLogViewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        
        self.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func saveToGallery(_ currentCard: CardModel) {
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        let folderID = currentCard.country!
        let values = [
            "imageURL": currentCard.imageURL!,
            "name": currentCard.name!,
            "country": currentCard.country!,
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        
        ref.child("folder").child(currentUser).child(currentCard.country!).observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                print("country folder does not exist!!!")
                let countryCodeGenerated = Locale(identifier: "en_US_POSIX").isoCode(for: currentCard.country!)!
                DataManager.createFolder(title: currentCard.country!, subtitle: "0", countryCode: countryCodeGenerated)
            }
            ref.child("folder").child(currentUser).child(folderID).child("photo").childByAutoId().setValue(values) { (err, ref) in
                if err != nil {return}
                DataManager.updateFolderPhotoCount(folderIDToUploadPhoto: folderID)
            }
        }
    
    }
    
}

