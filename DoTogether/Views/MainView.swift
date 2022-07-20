//
//  MainView.swift
//  DoTogether
//
//  Created by Long Sen on 7/5/22.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject private var vm = MainViewModel()
    @State private var addFriendView = false
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            if isEditing {
                Group {
                    ZStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            Text("Add Item")
                                .font(.system(size: 25, weight: .medium, design: .default))
                            Spacer()
                        }
                        Button {
                            withAnimation {
                                isEditing = false
                            }
                        } label: {
                            Text("X")
                                .font(.system(size: 25, weight: .bold, design: .default))
                        }
                    }
                    NewTaskView(task: $task, taskType: $taskType)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.primary.opacity(0.25)))
                        .frame(height: 150)
                }
                .padding([.horizontal])
            }
            ScrollView {
                VStack(alignment: .leading) {
                    if !isEditing {
                        Text(vm.currentUser?.email ?? "None")
                        friendsView
                        Text("Items")
                            .font(.title)
                    }
                    dummyView
                    ForEach(0..<vm.tasks.count, id:\.self) { index in
                        TaskView(task: vm.tasks[index], user: vm.currentUser)
                            .padding(.bottom, 20)
                    }
                }
                .padding([.horizontal])
                .sheet(isPresented: $addFriendView,onDismiss: nil) {
                    AddFriendView(user: vm.currentUser)
                }
            }
            .onTapGesture {
                if isEditing {
                    discardAlert = true
                }
            }
            Spacer()
            bottomButton
        }
        .environmentObject(vm)
    }
    
    private var addNewTaskButton: some View {
        Button {
            withAnimation {
                isEditing = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(.purple)
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
            .frame(width: 80, height: 50)
        }
    }
    
    private var saveNewTaskButton: some View {
        HStack {
            Spacer()
        Button {
            vm.storeNewTask(task: task, type: taskType)
            task = ""
            taskType = .private
            isEditing = false
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(task.isEmpty ? .gray : .purple)
                Text("Save")
                    .foregroundColor(.white)
                    .font(.title)
            }
            .frame(width: 80, height: 50)
        }
        .disabled(task.isEmpty)
        }
        .padding([.horizontal])
    }
    
    private var bottomButton: some View {
        Group {
        if isEditing {
            saveNewTaskButton
        } else {
            addNewTaskButton
        }
        }
    }
    
    @State private var task = ""
    @State private var taskType: Task.TaskType = .private
    
    private var friends: some View {
        Group {
            if let friends = vm.currentUser?.friends {
                ForEach(friends, id: \.self) { friend in
                    VStack{
                        ZStack {
                            RoundedRectangle(cornerRadius: 50).stroke()
                            Image(systemName: "person")
                        }
                        .frame(width: 50, height: 50)
                        Text(name(of: friend))
                    }
                }
            }
        }
    }
    
    private func name(of user: String) -> String {
        let rename = user.replacingOccurrences(of: "@gmail.com", with: "")
        if rename.count <= 5 {
            return rename
        }
        else {
            return rename.prefix(5) + ".."
        }
    }
    
    private var friendsView: some View {
        Group {
            Text("Friends")
                .font(.title)
            HStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color(.init(white: 0.75, alpha: 1)))
                        Button {
                            addFriendView = true
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                    .frame(width: 50, height: 50)
                    Text("Add")
                        .foregroundColor(.gray)
                }
                friends
                Spacer()
            }
        }
    }
    
    @State private var discardAlert = false
    
    private var tasksView: some View {
        ForEach(vm.tasks) { task in
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.primary.opacity(0.25))
                Text(task.text)
                    .padding()
            }
            .frame(minHeight: 100)
        }
        .alert(isPresented: $discardAlert) {
            Alert(title: Text("Discard changes?"), message: Text("If you leave now, you'll lose the changes you've made."), primaryButton: .default(Text("Discard"), action: {
                isEditing = false
            }), secondaryButton: .cancel(Text("Keep Editing")))
        }
    }
    
    private var dummyView: some View {
        HStack() {
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//        LoginView()
//            .preferredColorScheme(.dark)
    }
}
