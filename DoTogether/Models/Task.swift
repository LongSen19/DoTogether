//
//  Task.swift
//  DoTogether
//
//  Created by Long Sen on 7/10/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Task: Codable, Identifiable {
    @DocumentID var id: String?
    var text: String
    let timestamp: Date
    let owner: String
    var joined: [String]
    var type: TaskType
    
    enum TaskType: String, Codable {
        case `private` = "private"
        case friend = "friend"
        case open = "open"
    }
}
