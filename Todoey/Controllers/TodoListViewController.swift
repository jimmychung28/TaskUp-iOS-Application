//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-17.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import CoreData
class TodoListViewController: UITableViewController{

    var itemArray=[Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
  
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
       
//        context.delete(itemArray[indexPath.row])
//         itemArray.remove(at: indexPath.row)
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

           let newItem=Item(context: self.context)
            newItem.title=textField.text!
            newItem.done=false
            newItem.parentCategory=self.selectedCategory
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

        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    func loadItems(with request: NSFetchRequest<Item>=Item.fetchRequest(),predicate: NSPredicate?=nil){
        
        let categoryPredicate=NSPredicate(format: "parentCategory.name MATCHES %@",selectedCategory!.name!)
        if let additionalPredicate=predicate {
            request.predicate=NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate=categoryPredicate
        }

        do{
            itemArray=try context.fetch(request)
        }catch{
            print("Error fetching data from context\(error)")
        }
    }
    

}

extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item>=Item.fetchRequest()
       let predicate=NSPredicate(format: "title CONTAINS[cd] %&", searchBar.text!)
        
        request.sortDescriptors=[NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate:predicate )
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
