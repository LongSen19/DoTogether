//
//  ProfileView.swift
//  DoTogether
//
//  Created by Long Sen on 7/19/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            imageView
            Text("name")
            Form {
                Section {
                    Text("About")
                    Text("Premium")
                    Text("Log Out")
                }
            }
        }
    }
    
    var imageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 200).stroke()
            Image(systemName: "person.fill")
        }
        .frame(width: 200, height: 200)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
