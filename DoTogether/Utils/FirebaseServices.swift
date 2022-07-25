//
//  FirebaseServices.swift
//  DoTogether
//
//  Created by Long Sen on 7/22/22.
//

import Foundation
import SwiftUI
//import UIKit

struct FirebaseServices {
    static func createNewAccount(email: String, password: String, completion:@escaping (Bool) -> ()) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: ", error)
                completion(false)
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.storeUserInformation(email: email, password: password) { isStoredUserInfo in
                completion(isStoredUserInfo)
            }
        }
    }
    
    static func loginUser(email: String, password: String, completion: @escaping (Bool) -> ()) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to login user \(error)")
                completion(false)
                return
            }
            print("Successfully logged in as user \(result?.user.uid ?? "")")
            completion(true)
        }
        print("finished login")
    }
    
    
    static func storeUserInformation(email: String, password: String, completion: @escaping (Bool) -> ()) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": email, "uid": uid, "profileImageUrl": "", "friends": [], "sent": [], "received": []] as [String : Any]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .setData(userData) { error in
                if let error = error {
                    print(error)
                    completion(false)
                    return
                }
                print("Successfully stored user infor to firestore")
                completion(true)
            }
    }
    
    static func storeUserProfileImageUrl(_ profileImageUrl: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .updateData(["profileImageUrl": profileImageUrl]) { error in
                if let error = error {
                    print("Failed to store user profile image url \(error)")
                    return
                }
                print("Succefully store user profile image url")
            }
    }
    
    static func persistImageToStorage(image: UIImage?) {
    //        let filename = UUID().uuidString
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
            ref.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
//                    self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                    print("Failed to push image to Storage: \(err)")
                    return
                }
    
                ref.downloadURL { url, err in
                    if let err = err {
//                        self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                        print("Failed to retrieve downloadURL: \(err)")
                        return
                    }
    
//                    self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                    print(url?.absoluteString ?? "")
    
                    guard let url = url else { return }
                    self.storeUserProfileImageUrl(url.absoluteString)
//                    FirebaseServices.storeUserInformation(imageProfileUrl: url){ isStored in
//                        print("store image to firestore \(isStored)")
//                    }
                }
            }
        }
}
