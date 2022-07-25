//
//  ProfileView.swift
//  DoTogether
//
//  Created by Long Sen on 7/19/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var vm: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    let didLogout: () -> ()
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    
    var body: some View {
        VStack {
            imageView
            Text(vm.currentUser?.conventionName ?? "")
            Form {
                Section {
                    Text("About")
                    Text("Premium")
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        print("did log out")
                        didLogout()
                    }, label: {
                        Text("Log out")
                            .foregroundColor(.red)
                    })
                }
            }
            .actionSheet(isPresented: $showActionSheet, content: {
                ActionSheet(title: Text("Change Profile Image"), message: nil, buttons: [.default(Text("Confirm"), action: {
                        showImagePicker = true }),.destructive(Text("Cancel"))])
            })
        }
        .sheet(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @State private var image: UIImage?
    @State var isAnimating: Bool = true
    var imageView: some View {
        Button(action: {
            showActionSheet = true
        }, label: {
            ImageView(url: vm.currentUser?.profileImageUrl ?? "", in: 200)
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static let vm = MainViewModel()
    static var previews: some View {
        ProfileView {
            
        }
        .environmentObject(vm)
        .preferredColorScheme(.dark)
    }
}
