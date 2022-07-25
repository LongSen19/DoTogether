//
//  TaskViewModel.swift
//  DoTogether
//
//  Created by Long Sen on 7/17/22.
//

import Foundation
import Firebase

class TaskViewModel: ObservableObject {
    
    @Published var task: Task
    @Published var currentUser: User?
    @Published var joiners: [User] = []
    
    init(task: Task, user: User?) {
        print("init task view model")
        self.task = task
        self.currentUser = user
        if let uid = task.id {
            fetchTask(uid: uid)
        }
    }
    
    deinit {
        print("de init task view model")
    }
    
    private var firestoreListener: ListenerRegistration?
    
    private func fetchTask(uid: String) {
        firestoreListener?.remove()
        firestoreListener = FirebaseManager.shared.firestore.collection("tasks")
            .document(uid)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to fetch my current task \(error)")
                    return
                }
                    do {
                        let aTask: Task? = try querySnapshot?.data(as: Task.self)
                        if let aTask = aTask {
                            self.task = aTask
                        }
                        self.fetchJoiners()
                    } catch {
                        print("some error when fetching a task why \(error)")
                    }
            }
    }
    
    private func fetchJoiners() {
        joiners.removeAll()
        FirebaseManager.shared.firestore.collection("users")
            .whereField("email", in: task.joined)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Fail to fetch a friend \(error)")
                    return
                }
                querySnapshot?.documents.forEach({ document in
                    do {
                        let joiner = try document.data(as: User.self)
                        self.joiners.append(joiner)
                    } catch {
                        print("Catch error when fetching friends")
                    }
                })
            }
    }
    
    var isMyTask: Bool {
        guard let currentUser = currentUser else {
            return false
        }
        return task.owner == currentUser.email
    }
    
    var isJoined: Bool {
        guard let currentUser = currentUser else {
            return false
        }

        return task.joined.contains(currentUser.email)
    }
    
    func handleJoin() {
        print("handle Join")
        guard let currentUser = currentUser else {
            return
        }
        if let index = task.joined.firstIndex(where:{$0 == currentUser.email}) {
            print("remove")
            task.joined.remove(at: index)
        }
        else {
            print("add")
            task.joined.append(currentUser.email)
        }
        updateTaskToFirestore()
    }
    
    func updateTaskToFirestore() {
        guard let uid = task.id else { return }
        let newTask = [
            FirebaseConstants.text : task.text,
            FirebaseConstants.timestamp: task.timestamp,
            FirebaseConstants.owner: task.owner,
            FirebaseConstants.joined: task.joined,
            FirebaseConstants.type: task.type.rawValue] as [String: Any]
        
        FirebaseManager.shared.firestore.collection("tasks")
            .document(uid)
            .setData(newTask) { error in
                if let error = error {
                    print("Failed to save new task: \(error)")
                    return
                }
                print("Successfully updated task to firestore")
            }
    }
}
