//
//  AddFriendViewModel.swift
//  DoTogether
//
//  Created by Long Sen on 7/8/22.
//

import SwiftUI
import Firebase


class AddFriendViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var users = [User]()
    @Published var currentUser: User?

    init(currentUser: User?) {
        print("innit add friend view model")
        self.currentUser = currentUser
        fetchAllUsers()
    }

    deinit {
        print("de init Add Friend View Model")
    }

    func isSentRequestUser(_ user: String) -> Bool {
        if let currentUser = currentUser {
            if currentUser.sent.contains(user) {
                return true
            }
        }
        return false
    }


    func fetchAllUsers() {
        if let currentUser = currentUser {
            users.removeAll()
            FirebaseManager.shared.firestore
                .collection("users")
                .getDocuments { documentsSnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to fetch users \(error)"
                        print("Failed to fetch users \(error)")
                        return
                    }
                    documentsSnapshot?.documents.forEach({ snapshot in
                        do  {
                            let user = try snapshot.data(as: User.self)
                            if currentUser.id != user.id && !currentUser.friends.contains(user.email) {
                                self.users.append(user)
                            }
                        } catch {
                            self.errorMessage = "some error here \(error)"
                            print("some error here \(error)")
                        }
                    })
                }
        }
    }

    func handleRequest(of user: String) {
        if let index = currentUser?.sent.firstIndex(where: {$0 == user}) {
            currentUser?.removeSent(at: index)
            removeSentRequest(to: user)
        } else {
            currentUser?.addSent(user: user)
            sentRequest(to: user)
        }
        if let currentUser = currentUser {
            updateUserToFirestore(user: currentUser)
        }
    }

    private func updateUserToFirestore(user: User){
        guard let uid = user.id else { return }
        do {
            try FirebaseManager.shared.firestore.collection("users")
                .document(uid)
                .setData(from: user)
        } catch {
            print("Failed to update user to Firestore")
        }
    }

    func sentRequest(to user: String) {
        if let currentUser = currentUser {
            FirebaseManager.shared.firestore.collection("users")
                .whereField("email", isEqualTo: user)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to fetch toUser \(error)"
                        print("Failed to fetch toUser \(error)")
                        return
                    }
                    else {
                        let document = querySnapshot?.documents.first
                        do {
                            var toUser = try document?.data(as: User.self)
                            toUser?.addReceived(user: currentUser.email)
                            if let toUser = toUser {
                                self.updateUserToFirestore(user: toUser)
                            }
                        } catch {
                            print("Failed to decode to User")
                        }
                    }
                }

        }
    }

    func removeSentRequest(to user: String) {
        if let currentUser = currentUser {
            FirebaseManager.shared.firestore.collection("users")
                .whereField("email", isEqualTo: user)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to fetch toUser removing\(error)"
                        print("Failed to fetch toUser removing \(error)")
                        return
                    }
                    else {
                        let document = querySnapshot?.documents.first
                        do {
                            var toUser = try document?.data(as: User.self)
                            toUser?.removeReceived(user: currentUser.email)
                            if let toUser = toUser {
                                self.updateUserToFirestore(user: toUser)
                            }
                        } catch {
                            print("Failed to decode to User removing")
                        }
                    }
                }
        }
    }

    func handleFriendRequest(of friend: String, accept: Bool) {
        guard var currentUser = currentUser, currentUser.received.contains(friend) else {
            print("No current user found")
            return
        }
        if accept {
            currentUser.friends.append(friend)
        }
        currentUser.removeReceived(user: friend)
        updateUserToFirestore(user: currentUser)
        
        FirebaseManager.shared.firestore.collection("users")
            .whereField("email", isEqualTo: friend)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch friend email \(error)")
                    return
                }
                let document = querySnapshot?.documents.first
                do {
                    let user = try document?.data(as: User.self)
                    guard var user = user else { return }
                    guard let index = user.sent.firstIndex(of: currentUser.email) else {
                        print("Failed to find a friend from sender")
                        return }
                    if accept {
                        user.friends.append(currentUser.email)
                    }
                    user.removeSent(at: index)
                    self.updateUserToFirestore(user: user)
                    print("Successfully add friend from sender")
                } catch {
                    print("Failed to fetch friend email here \(error)")
                }
            }
    }
}
