//
//  TasksView.swift
//  DoTogether
//
//  Created by Long Sen on 7/14/22.
//

import SwiftUI

struct TaskView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var offsetWidth: CGFloat = 0
    //    @State private var isDelete = false
    
    init(task: Task, user: User?) {
        print("init view")
        self.taskViewModel = .init(task: task, user: user)
//        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskID: taskID, user: user))
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                taskView
                    .frame(width: geometry.size.width)
                if isDelete {
                    completeButton
                    deleteButton
                }
            }
            .offset(x: offsetWidth)
            .gesture(dragGesture)
        }
        .frame(height: 150)
    }
    
    
    @State private var isDelete = false
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                withAnimation {
                    self.offsetWidth = gesture.translation.width
                }
            }
            .onEnded { _ in
                print("width \(self.offsetWidth)")
                if self.offsetWidth < 0 {
                    withAnimation {
                        self.offsetWidth = -130
                        self.isDelete = true
                    }
                }
                if self.offsetWidth > 0 {
                    withAnimation {
                        self.offsetWidth = 0
                        self.isDelete = false
                    }
                }
            }
    }
    
    private var taskView: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.primary.opacity(0.25))
            if taskViewModel.isMyTask
            {
                ownerView
            }
            else {
                joinedView
                    .onTapGesture {
                        print("tap here")
                        taskViewModel.handleJoin()
                    }
            }
            if let task = taskViewModel.task {
                VStack(alignment: .leading) {
                    Text(task.text)
                        .padding(.top,10)
                        .padding()
                    HStack {
                        joinersView
                        Spacer()
                        taskTypeView(type: task.type)
                    }
                    .padding()
                }
            }
        }
    }
    
    private var deleteButton: some View {
        Button {
            withAnimation {
                self.offsetWidth = 0
                self.isDelete = false
                self.mainViewModel.delete(a: self.taskViewModel.task)
            }
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.red)
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .frame(width: 60)
    }
    
    private var completeButton: some View {
        Button {
            withAnimation {
                self.offsetWidth = 0
                self.isDelete = false
                self.mainViewModel.complete(a: self.taskViewModel.task)
                    }
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.blue)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .frame(width: 60)
    }
    
    private var ownerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).foregroundColor(.gray)
            Text("Owner")
                .font(.title2)
        }
        .frame(width: 70, height: 30)
        .position(x: 50, y: -2)
    }
    
    private var joinedView: some View {
        HStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 5).foregroundColor(taskViewModel.isJoined ? .blue : .green)
                Text(taskViewModel.isJoined ? "Joined" : "Join")
                    .font(.title2)
            }
            .frame(width: 70, height: 30)
        }
        .padding([.horizontal])
    }
    
    private var joinersView: some View {
        Group {
            if taskViewModel.joiners.count <= 3 {
                ForEach(0..<taskViewModel.joiners.count, id:\.self) { index in
                    ImageView(url: taskViewModel.joiners[index].profileImageUrl, in: 50)
                        .offset(x: Double(-index * 30), y: 0)
                }
            } else {
                ForEach(0..<3, id:\.self) { index in
                    ImageView(url: taskViewModel.joiners[index].profileImageUrl, in: 50)
                        .offset(x: Double(-index * 30), y: 0)
                }
                Text("+ \(taskViewModel.joiners.count - 3)")
                    .offset(x: Double(-60), y: 0)
            }
        }
    }
    
    private func taskTypeView(type: Task.TaskType) -> some View {
        if type == .private {
            return HStack {
                Image(systemName: "lock")
                Text("Private")
            }
        }
        else if type == .friend {
            return HStack {
                Image(systemName: "person.2")
                Text("Friends")
            }
        }
        else {
            return HStack {
                Image(systemName: "person.3")
                Text("Open")
            }
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static let task: Task = Task(id: "abc", text: "abcd", timestamp: Date(), owner: "long7@gmail.com", joined: ["long7@gmail.com"], type: Task.TaskType.open)
    static let user: User = User(id: "7ABn25Ll3QZvysqlVbVe5IbII8k2", email: "long7@gmail.com", profileImageUrl: "", friends: ["long8@gmail.com"], sent: [], received: [])
    static let vm = MainViewModel()
    static var previews: some View {
        //        LoginView()
        TaskView(task: task, user: user)
                    .environmentObject(vm)
    }
}

