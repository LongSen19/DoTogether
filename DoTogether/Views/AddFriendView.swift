//
//  AddFriendView.swift
//  DoTogether
//
//  Created by Long Sen on 7/7/22.
//

import SwiftUI

struct AddFriendView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var search = ""
    @State private var isSearch = false
    @EnvironmentObject var vm: MainViewModel
    
//    init(user: User) {
//        vm = .init(currentUser: user)
//    }
    
    var body: some View {
        VStack {
            ScrollView {
                Text(vm.currentUser?.email ?? "None")
                searchField
                    .padding()
                if isSearch {
                    userListView
                } else {
                    description
                    received
                    sent
                    Spacer()
                }
            }
            done
        }
    }
    
    private var searchField: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(.init(white: 0.8, alpha: 0.5)))
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.gray)
                    TextField("Search", text: $search)
                        .font(.title2)
                }
                .onTapGesture {
                    withAnimation {
                        vm.fetchAllUsers()
                        self.isSearch = true
                    }
                }
                .padding(10)
            }
            .frame(height: 50)
            if isSearch {
                Button {
                    withAnimation {
                        self.isSearch = false
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(.gray)
                        .font(.body)
                }
                
            }
            
        }
    }
    
    private var description: some View {
        VStack {
            Text("Connect with Friends")
                .font(.title)
                .padding([.bottom], 5)
            Text("Add friends to share your items and updates.")
                .foregroundColor(.gray)
            Text("Only friends can see what you're up to.")
                .foregroundColor(.gray)
        }
    }
    
    private var received: some View {
        VStack {
            HStack {
                Text("Received")
                    .font(.system(size: 25, weight: .medium, design: .default))
                Spacer()
            }
            if let received = vm.currentUser?.received {
                ForEach(received, id:\.self) { user in
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 25))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 40).stroke(lineWidth: 2))
                        Text(user)
                            .font(.title2)
                        Spacer()
                        Button {
                            vm.handleFriendRequest(of: user, accept: true)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.purple)
                                Text("Accept")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 100, height: 40)
                        }
                        
                        Button {
                            vm.handleFriendRequest(of: user, accept: false)
                        } label: {
                            Text("X")
                                .font(.system(size: 40, weight: .regular, design: .default))
//                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func userView(of user: String) -> some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.system(size: 25))
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(lineWidth: 2))
            Text(user)
                .font(.title2)
            Spacer()
            Group {
                if vm.isSentRequestUser(user) {
                    ZStack {
                        Circle()
                            .foregroundColor(.purple)
                            .frame(height: 40)
                        Image(systemName: "checkmark")
                            .font(.title2)
                    }
                } else {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 40)
            .onTapGesture {
                print("handle request")
                vm.handleRequest(of: user)
            }
        }
    }
    
    private var sent: some View {
        VStack {
            HStack {
                Text("Sent")
                    .font(.system(size: 25, weight: .medium, design: .default))
                Spacer()
            }
            if let sent = vm.currentUser?.sent {
                ForEach(sent, id:\.self) { user in
                    userView(of: user)
                }
            }
        }
        .padding()
    }
    
    private var done: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .foregroundColor(Color(.init(white: 1, alpha: 0.15)))
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .black, design: .default))
            }
            
        }
        .frame(height: 50)
    }
    
    private var userListView: some View {
        ScrollView {
            ForEach(vm.users) { user in
                userView(of: user.email)
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .preferredColorScheme(.dark)
    }
}
