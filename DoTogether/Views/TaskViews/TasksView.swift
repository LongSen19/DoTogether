//
//  TasksView.swift
//  DoTogether
//
//  Created by Long Sen on 7/14/22.
//

import SwiftUI

struct TasksView: View {
    
    @EnvironmentObject var vm: MainViewModel
    
    var body: some View {
        VStack{
        ForEach(vm.tasks) { task in
            taskView(task: task)
                .padding(.bottom)
            }
        }
    }
    
    private func taskView(task: Task) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.primary.opacity(0.25))
            if vm.isMyTask(task: task)
            {
            ownerView
            }
//                    .opacity(vm.isMyTask(task: task) ? 1 : 0)
            else {
            joinedView(task: task)
                    .onTapGesture {
                        print("tap here")
                        vm.handleJoin(task: task)
                    }
            }
            VStack(alignment: .leading) {
            Text(task.text)
                .padding(.top,10)
                .padding()
            HStack {
                joinersView(task: task)
                Spacer()
                taskTypeView(type: task.type)
            }
            .padding()
            }
        }
        .frame(minHeight: 100)
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
    
    private func joinedView(task: Task) -> some View {
        HStack {
        Spacer()
        ZStack {
            RoundedRectangle(cornerRadius: 5).foregroundColor(vm.isJoined(task: task) ? .blue : .green)
            Text(vm.isJoined(task: task) ? "Joined" : "Join")
                .font(.title2)
            }
        .frame(width: 70, height: 30)
        }
        .padding([.horizontal])
    }
    
    private func joinersView(task: Task) -> some View {
        Group {
            if task.joined.count <= 3 {
                ForEach(0..<task.joined.count, id:\.self) { index in
                    joinerView
                        .offset(x: Double(-index * 30), y: 0)
                }
            } else {
                ForEach(0..<3, id:\.self) { index in
                    joinerView
                        .offset(x: Double(-index * 30), y: 0)
                }
                Text("\(task.joined.count - 3)")
                    .offset(x: Double(-90), y: 0)
            }
        }
    }
    
    private var joinerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50).stroke()
                Image(systemName: "person")
        }
        .frame(width: 50, height: 50)
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
    static let vm = MainViewModel()
    static var previews: some View {
        TasksView()
            .environmentObject(vm)
    }
}

