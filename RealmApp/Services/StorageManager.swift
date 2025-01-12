//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Task List
    func fetchData<T>(_ type: T.Type) -> Results<T> where T: RealmFetchable {
        realm.objects(T.self)
    }
    
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskList: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.title = newValue
        }
    }

    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func sort(_ taskLists: Results<TaskList>, byKeyPath: String) -> Results<TaskList>{
        let sortedTaskLists = realm.objects(TaskList.self).sorted(byKeyPath: byKeyPath)
        return sortedTaskLists
    }
//    func sorted(taskLists: Result<TaskList>){
//        let predicate = NSPredicate(format: "title BEGINSWITH [c]%@", taskLists)
//        let sortedTaskList = realm.objects(TaskList.self).filter(predicate).sorted(byKeyPath: "title")
//        
//    }

    // MARK: - Tasks
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [task, note])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    func deleteTask (task: Task){
        write {
            realm.delete(task)
        }
    }
    
    func editTask(task:Task, newTitile: String, newNote: String){
        write {
            task.title = newTitile
            task.note = newNote
        }
    }
    
    func doneTask(task: Task){
        write {
            task.setValue(true, forKey: "isComplete")
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
    
    
}
