//
//  NewTaskView.swift
//  DoTogether
//
//  Created by Long Sen on 7/13/22.
//

import SwiftUI

struct NewTaskView: View {
    @Binding var task: String
    @Binding var taskType: Task.TaskType
    
    var body: some View {
        ScrollView {
        ZStack(alignment: .topLeading) {
            if task.isEmpty {
                Text("eg. Go to gym")
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(EdgeInsets(top: 7, leading: 2, bottom: 0, trailing: 0))
                    .padding()
            }
            VStack {
                TextEditor(text: $task.max(500))
                    .padding()
            HStack {
                Text("\(task.count)/500")
                Spacer()
                taskTypeView()
                    .onTapGesture {
                        changeTaskType()
                    }
            }
            .padding()
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 5).foregroundColor(.clear))
        .frame(height: 150)
        }
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }.onDisappear {
            UITextView.appearance().backgroundColor = nil
        }
    }
    
    private func taskTypeView() -> some View {
        if taskType == .private {
            return HStack {
                Image(systemName: "lock")
                Text("Private")
            }
        }
        else if taskType == .friend {
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

    private func changeTaskType() {
        if taskType == .private {
            taskType = .friend
        }
        else if taskType == .friend {
            taskType = .open
        }
        else {
            taskType = .private
        }
    }
}


struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskView(task: Binding.constant(""), taskType: Binding.constant(.private))
    }
}


extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}

