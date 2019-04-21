//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-19.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import RealmSwift
class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newCategory=Category()
            newCategory.name=textField.text!
            self.saveCategories(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="Create new Category"
            textField=alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion:nil)
    }
    
    //MARK:-TableView Datasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
      
        cell.textLabel?.text=categoryArray?[indexPath.row].name ?? "No Categories Added"
      
        return cell
    }
    
    
    //MARK:-Data Manipulation Methods
    func saveCategories(category:Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    func loadCategories(){
        categoryArray=realm.objects(Category.self)
        tableView.reloadData()
        
    }
    
    //MARK:-TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath=tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
}
