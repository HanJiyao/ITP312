//
//  SwiftUIGallery.swift
//  ITP312
//
//  Created by tyr on 2/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

//create design search --> navigate on one picture swiftui --> ARKIT --> purchase
import SwiftUI

struct SwiftUIGallery: View {
    
    @State var isActive = false
    @State var text = "Hello"
    
    var body: some View {
        NavigationView {
            
            VStack {
                Button(action: {self.isActive.toggle()}) {
                    Text("Go to one photo")
                }
                List {
                    ForEach(0...30, id: \.self) { _ in
                        Text("hello")
                    }
                    
                }
            }.navigationBarTitle("Watar")
                .navigationBarItems(leading: Text("top item"))
                .sheet(isPresented: $isActive) {
                    CustomController()
                    
            }
        }
        
    }
}


struct SwiftUIGallery_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIGallery()
    }
}

struct Restaurant: Identifiable {
    var id = UUID()
    var name: String
}

struct CustomController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomController>) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "GalleryStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "Gallery") as! GalleryViewController
        controller.idToChange = "helloxxx"
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomController>) {
//        uiViewController.galleryLabel.text = "hello"
//        print("updating uiviewcontroller")
    }
    
}


//https://stackoverflow.com/a/58250271
class ChildHostingController: UIHostingController<SwiftUIGallery> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: SwiftUIGallery());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
