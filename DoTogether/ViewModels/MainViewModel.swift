//
//  MainViewModel.swift
//  DoTogether
//
//  Created by Long Sen on 7/6/22.
//

import Foundation
import Firebase

class MainViewModel: ObservableObject {
    
    @Published var isUserCurrentlyLoggedOut = true
    @Published var currentUser: User?
    @Published var errorMessage = ""
    @Published var users = [User]()
    @Published var tasks = [Task]()

    
    init() {
        print("init main view model")
        fetchCurrentUser()
//        fetchMyTasks()
//        fetchMyFriendTasks()
    }
    
    private var firestoreListener: ListenerRegistration?

    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        firestoreListener?.remove()

        firestoreListener = FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                print("fetch current user in main view model")
                do {
                    self.currentUser = try querySnapshot?.data(as: User.self)
                    self.fetchMyTasks()
                    self.fetchFriendTasks()
                    self.fetchOpenTasks()
                    self.tasks.sort(by: {$0.timestamp > $1.timestamp})
                } catch {
                    print("some error \(error)")
                }
            }
    }

    deinit {
        print("de init")
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
    
    func storeNewTask(task: String, type: Task.TaskType) {
        guard let currentUser = currentUser else {
            return
        }
        let newTask = [
            FirebaseConstants.text : task,
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.owner: currentUser.email,
            FirebaseConstants.joined: [currentUser.email],
            FirebaseConstants.type: type.rawValue] as [String: Any]
        
        FirebaseManager.shared.firestore.collection("tasks")
            .document()
            .setData(newTask) { error in
                if let error = error {
                    self.errorMessage = "Failed to save new task: \(error)"
                    print("Failed to save new task: \(error)")
                    return
                }
                print("Successfully save new task to firestore")
            }
    }
    
    private var myTasksFirestoreListener: ListenerRegistration?
    
    private func fetchMyTasks() {
        guard let currentUser = currentUser else {
            return
        }

        myTasksFirestoreListener?.remove()
        myTasksFirestoreListener = FirebaseManager.shared.firestore.collection("tasks")
            .whereField("owner", isEqualTo: currentUser.email)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch my task \(error)")
                    return
                }
                querySnapshot?.documents.forEach({ documentSnapshot in
                    do {
                        let task = try documentSnapshot.data(as: Task.self)
                        self.checkAndAddTask(task)
                        print("all my task \(self.tasks)")
                    } catch {
                        print("Failed to fetch my task \(error)")
                    }
                })
//                self.tasks.sort(by: {$0.timestamp > $1.timestamp})
            }
    }
    
    private var myFriendTasksFirestoreListener: ListenerRegistration?
    
    private func fetchFriendTasks() {
        guard let currentUser = currentUser else {
            return
        }
        
        guard !currentUser.friends.isEmpty else { return }

        myFriendTasksFirestoreListener?.remove()
        myFriendTasksFirestoreListener = FirebaseManager.shared.firestore.collection("tasks")
            .whereField("owner", in: currentUser.friends)
            .whereField("type", isEqualTo: "friend")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch my task \(error)")
                    return
                }
                querySnapshot?.documents.forEach({ documentSnapshot in
                    do {
                        let task = try documentSnapshot.data(as: Task.self)
                        self.checkAndAddTask(task)
//                        print("all my task \(self.tasks)")
                    } catch {
                        print("Failed to fetch my task \(error)")
                    }
                })
//                self.tasks.sort(by: {$0.timestamp > $1.timestamp})
            }
    }
    
    private var openTasksFirestoreListener: ListenerRegistration?
    
    private func fetchOpenTasks() {
        guard let currentUser = currentUser else {
            return
        }
        
        guard !currentUser.friends.isEmpty else { return }

        openTasksFirestoreListener?.remove()
        openTasksFirestoreListener = FirebaseManager.shared.firestore.collection("tasks")
            .whereField("type", isEqualTo: "open")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch my task \(error)")
                    return
                }
                querySnapshot?.documents.forEach({ documentSnapshot in
                    do {
                        let task = try documentSnapshot.data(as: Task.self)
                        let joined = task.joined
                        if Set(joined).intersection(currentUser.friends).count >= 1 {
                            self.checkAndAddTask(task)
                        }
//                        print("fetch here some how")
//                        print("all my task \(self.tasks)")
                    } catch {
                        print("Failed to fetch my task \(error)")
                    }
                })
//                self.tasks.sort(by: {$0.timestamp > $1.timestamp})
            }
    }
    
    private func checkAndAddTask(_ task: Task) {
        if !tasks.contains(where: {$0.id == task.id}) {
//            tasks.append(task)
            tasks.insert(task, at: 0)
        }
    }
    

    
    func printMyTasks() {
        print("my tasks \(self.tasks)")
    }
}
