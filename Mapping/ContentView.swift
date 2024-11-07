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
        MapView()
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}
//struct ContentView: View {
//    @EnvironmentObject var userManager: UserManager
//    enum Tab {
//        case map, myInfo
//    }
//    
//    @State private var selected: Tab = .map
//    
//    var body: some View {
//        ZStack{
//            TabView(selection: $selected) {
//                Group{
//                    MapView()
//                        .tag(Tab.map)
//                    MyInfo()
//                        .tag(Tab.myInfo)
//                }
//            }
//            .toolbar(.hidden, for: .tabBar)
//            VStack{
//                Spacer()
//                tabBar
//            }
//        }
//        
//    }
//    
//    var tabBar: some View {
//        HStack {
//            Spacer()
//            Button {
//                selected = .map
//            } label: {
//                VStack(alignment: .center) {
//                    Image(systemName: "map.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 22)
//                    if selected == .map {
//                        Text("지도")
//                            .font(.system(size: 11))
//                    }
//                }
//            }
//            .foregroundStyle(selected == .map ? Color.accentColor : Color.gray)
//            Spacer()
//            Button {
//                selected = .myInfo
//            } label: {
//                VStack(alignment: .center) {
//                    Image(systemName: "person.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 22)
//                    if selected == .myInfo {
//                        Text("내 정보")
//                            .font(.system(size: 11))
//                    }
//                }
//            }
//            .foregroundStyle(selected == .myInfo ? Color.accentColor : Color.gray)
//            Spacer()
//        }
//        //.padding()
//        .frame(height: 63)
//        .background {
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color.white)
//                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
//        }
//        .padding(.horizontal)
//    }
//}
