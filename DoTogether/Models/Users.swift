//
//  Users.swift
//  DoTogether
//
//  Created by Long Sen on 7/8/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
//    var id: String { uid }
//    let uid: String
    @DocumentID var id: String?
    let email: String
    let profileImageUrl: String
    var friends: [String]
    var sent: [String]
    var received: [String]
    
//    init(data: [String: Any]) {
//        self.uid = data["uid"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.friends = data["friends"] as? [String] ?? []
//        self.sents = data["sents"] as? [String] ?? []
//        self.friends = data["friends"] as? [String] ?? []
//
//    }
    
    mutating func addSent(user: String) {
        sent.append(user)
    }
    
    mutating func removeSent(at index: Int) {
        sent.remove(at: index)
    }
    
    mutating func addReceived(user: String) {
        received.append(user)
    }
    
    mutating func removeReceived(user: String) {
        print(received)
        print("remove \(user)")
        if let index = received.firstIndex(where: { $0 == user }) {
            print("got u")
            received.remove(at: index)
        }
        print("total \(received)")
    }
}
