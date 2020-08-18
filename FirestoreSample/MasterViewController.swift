//
//  MasterViewController.swift
//  FirestoreSample
//
//  Created by Tsutomu Ogasawara on 2020/08/18.
//  Copyright © 2020 ogaoga. All rights reserved.
//

import UIKit
import FirebaseFirestore

// タスクのデータ
struct Task {
  // Firestore の documentId
  var id: String
  // 登録日の文字列
  var date: String
  // 完了していたら true
  var completed: Bool
}

class MasterViewController: UITableViewController {

  var detailViewController: DetailViewController? = nil
  
  // local task list
  // テーブルに表示するデータはここに格納する。
  var tasks: [Task] = []

  // Firestore db
  let db = Firestore.firestore()
  let collectionName = "tasks"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    navigationItem.leftBarButtonItem = editButtonItem

    // Add button
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    // Listen the collection
    // ここで、コレクションの変更を監視して、変更があったらブロック内が実行される。
    db.collection(collectionName).order(by: "date")
      .addSnapshotListener { querySnapshot, error in
        // get task list from Firestore
        // Firestore から一覧を取得する。
        guard let documents = querySnapshot?.documents else {
          print("Error fetching documents: \(error!)")
          return
        }
        // set the list to the local
        // データを tasks に格納する。
        self.tasks = documents.map { document in
          let data = document.data()
          return Task(id: document.documentID, date: data["date"] as! String, completed: data["completed"] as! Bool)
        }
        // reload the table view
        // TableView を描画するよう指示を出す。
        self.tableView.reloadData()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  @objc
  func insertNewObject(_ sender: Any) {
    // 新しいタスクを挿入する。
    var ref: DocumentReference? = nil
    ref = db.collection(collectionName).addDocument(data: [
      "date": Date().description,
      "completed": false
    ]) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
      }
    }
  }
  
  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let task = tasks[indexPath.row]
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = task
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        detailViewController = controller
      }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let task = tasks[indexPath.row]
    cell.textLabel!.text = task.date
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // 選択されたセルのデータを削除する
      // Firestore のデータを削除することで、自動的にテーブルが更新される。
      let task = tasks[indexPath.row]
      db.collection(collectionName).document(task.id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        } else {
          print("Document successfully removed!")
        }
      }
    }
  }
}
