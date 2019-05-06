//
//  CategoryViewController.swift
//
//  Created by Jimmy Chung on 2019-04-19.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import UserNotifications
class CategoryViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    var center=UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            
        }
        loadCategories()
        tableView.separatorStyle = .none
        
       
    }


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Category", style: .default) { (action) in
            if textField.text?.trimmingCharacters(in: .whitespaces).isEmpty != true{
                let newCategory=Category()
                newCategory.name=textField.text!
                newCategory.backgroundColor=UIColor.randomFlat.hexValue()
                self.saveCategories(category: newCategory)
            }
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="Create new Category"
            textField=alertTextField
        }
         let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
        alert.addAction(action)
        alert.addAction(cancel)
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
        
        let cell=super.tableView(tableView, cellForRowAt: indexPath)
      
        cell.textLabel?.text=categoryArray?[indexPath.row].name ?? "No Categories Added"
       
        cell.backgroundColor=UIColor(hexString: categoryArray?[indexPath.row].backgroundColor ?? "ffffff")
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryArray?[indexPath.row].backgroundColor ?? "ffffff")!, returnFlat: true)
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
    @IBAction func InfoButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
    
    //MARK:-TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="goToItems"{
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath=tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
                destinationVC.center=center
            }
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
                if let categoryForDeletion=self.categoryArray?[indexPath.row]{
                    do{
                         try realm.write {
                                realm.delete(categoryForDeletion.items)
                               realm.delete(categoryForDeletion)
                            }
                        }catch{
                           print("Error deleting category,\(error)")
                        }
                   }
    }
}


