//
//  LoginViewModel.swift
//  DoTogether
//
//  Created by Long Sen on 7/5/22.
//

import Foundation


class LoginViewModel: ObservableObject {
    
    @Published var isLoginMode = false
    @Published var statusMessage = ""
    @Published var loggedIn = false
    
    init() {
      print("init Login View Model")
    }
    
    deinit {
        print("deinit Login View Model")
    }
    
    func handleAction(email: String, passwod: String) {
        self.statusMessage = "handling action"
        if isLoginMode {
            print("Should Log into Firebase with existing credentials")
            loginUser(email: email, password: passwod)
        } else {
            print("Register a new account inside of Firebase Auth")
            createNewAccount(email: email, password: passwod)
        }
    }
    
    private func createNewAccount(email: String, password: String) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: ", error)
                self.statusMessage = "Failed to create user: \(error)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.statusMessage = "Successfully creted user: \(result?.user.uid ?? "")"
            
            self.storeUserInformation(email: email, password: password)
        }
    }
    
    private func loginUser(email: String, password: String) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to login user \(error)")
                self.statusMessage = "Failed to login user \(error)"
                return
            }
            print("Successfully logged in as user \(result?.user.uid ?? "")")
            self.statusMessage = "Successfully logged in as user \(result?.user.uid ?? "")"
            self.loggedIn = true
        }
    }
    
    private func storeUserInformation(email: String, password: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": email, "uid": uid, "profileImageUrl": "", "friends": [], "sent": [], "received": []] as [String : Any]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .setData(userData) { error in
                if let error = error {
                    print(error)
                    self.statusMessage = "\(error)"
                    return
                }
                
                print("Successfully stored user infor to firestore")
                self.statusMessage = "Successfully stored user infor to firestore"
                self.loggedIn = true
            }
    }
}
