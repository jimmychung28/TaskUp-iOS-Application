//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-17.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import RealmSwift
class TodoListViewController: UITableViewController{
       let realm = try! Realm()
    var todoItems:Results<Item>?
    var selectedCategory: Category? {
        didSet{
           loadItems()
        }
    }
  
 
    override func viewDidLoad() {
        super.viewDidLoad()

     
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        // Configure the cell...
        
        if let item=todoItems?[indexPath.row]{
            cell.textLabel?.text=item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text="No Items Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(itemArray[indexPath.row])
        if let item=todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status \(error)")
            }
           
        }
//        context.delete(itemArray[indexPath.row])
//         itemArray.remove(at: indexPath.row)
//       self.todoItems[indexPath.row].done = !self.todoItems[indexPath.row].done
//        self.saveItems()
          tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
      
    }
    

 //Mark - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory=self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem=Item()
                        newItem.title=textField.text!
                        newItem.dataCreated=Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
               
            }
           
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField=alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    

    func loadItems(){
        todoItems=selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
      }
    
    

}

extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems=todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dataCreated", ascending: true)
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}
