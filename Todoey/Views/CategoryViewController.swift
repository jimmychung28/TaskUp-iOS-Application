//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-19.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController {
    
    var categoryArray=[Category]()
    
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newCategory=Category(context: self.context)
            newCategory.name=textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategories()
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
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category=categoryArray[indexPath.row]
        cell.textLabel?.text=category.name
      
        return cell
    }
    
    
    //MARK:-Data Manipulation Methods
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    func loadCategories(){
        let request:NSFetchRequest<Category>=Category.fetchRequest()
        do{
            categoryArray=try context.fetch(request)
        }catch{
            print("Error fetching category data \(error)")
        }
        
    }
    
    //MARK:-TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath=tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
}
