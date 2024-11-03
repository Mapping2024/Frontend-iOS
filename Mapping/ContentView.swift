//
//  ContentView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("지도")
                }
            
            MyInfo()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("내 정보")
                }
        }
        .font(.headline)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}
