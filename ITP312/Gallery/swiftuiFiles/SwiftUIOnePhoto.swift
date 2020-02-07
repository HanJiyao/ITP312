//
//  SwiftUIOnePhoto.swift
//  ITP312
//
//  Created by tyr on 3/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import SwiftUI

struct SwiftUIOnePhoto: View {
    var body: some View {
        TabView {
            
            Text("Favourites Screen")
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favourites")
            }
            Text("Friends Screen")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Friends")
            }
            Text("Nearby Screen")
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Nearby")
            }
        }
    }
}

struct SwiftUIOnePhoto_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIOnePhoto()
    }
}

