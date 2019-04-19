//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-17.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray=[item]()
    let dataFilePath=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let item=defaults.array(forKey: "TodoListArray")as?[item]{
//            itemArray=item
//        }
        loadItems()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        // Configure the cell...
        
        let item=itemArray[indexPath.row]
        cell.textLabel?.text=item.title
        cell.accessoryType = item.done==true ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(itemArray[indexPath.row])
        self.itemArray[indexPath.row].done = !self.itemArray[indexPath.row].done
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    

 //Mark - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Item", style: .default) { (action) in
           let newItem=item()
            newItem.title=textField.text!
           self.itemArray.append(newItem)
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField=alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func saveItems(){
        let encoder=PropertyListEncoder()
        do{
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }catch{
            print("Error encoding item array,\(error)")
        }
        self.tableView.reloadData()
    }
    func loadItems(){
        if let data=try? Data(contentsOf: dataFilePath!){
            let decoder=PropertyListDecoder()
            do{
            itemArray=try decoder.decode([item].self, from: data)
            }catch{
                print("Error decoding item array,\(error)")
            }
        }
    }
}
