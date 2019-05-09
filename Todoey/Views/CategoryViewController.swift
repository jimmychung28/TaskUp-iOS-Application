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
import SwipeCellKit
class CategoryViewController: SwipeTableViewController,colorViewControllerDelegate{
    func changeColor(color: UIColor,indexPath:IndexPath) {
        print("good")
        if let categoryForEditing=self.categoryArray?[indexPath.row]{
            
            do{
                try realm.write {
                    categoryForEditing.backgroundColor=color.hexString;
                    print("\(color.hexString)")
                }
            }catch{
                print("Error changing category color,\(error)")
            }
        }
        tableView.reloadData()
    }
    
    var orderNumber=0;
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    var center=UNUserNotificationCenter.current()
    var changeColorIndexPath:IndexPath?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            
        }
        loadCategories()
        tableView.separatorStyle = .none
        
       
    }
    @IBAction func rearrangeButton(_ sender: UIBarButtonItem) {
        self.tableView.isEditing = !self.tableView.isEditing
        if (editButton.title=="Done"){
            editButton.title="Rearrange"
            editButton.style = .plain
        }else{
            editButton.title="Done"
            editButton.style = .done
        }
        
        
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        

        do{
            try realm.write {
                let sourceObject = categoryArray![sourceIndexPath.row]
                let destinationObject = categoryArray![destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.order
                
                if sourceIndexPath.row < destinationIndexPath.row {

                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let object = categoryArray![index]
                        object.order -= 1
                    }
                } else {

                    for index in (destinationIndexPath.row..<sourceIndexPath.row){
                        let object = categoryArray![index]
                        object.order += 1
                    }
                }

                sourceObject.order = destinationObjectOrder
            }
        }catch{
            print("Error reordering \(error)")
        }
        self.tableView.reloadData()
    }


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Category", style: .default) { (action) in
            if textField.text?.trimmingCharacters(in: .whitespaces).isEmpty != true{
                let newCategory=Category()
                newCategory.name=textField.text!
                newCategory.backgroundColor=UIColor.randomFlat.hexValue()
                newCategory.order=self.orderNumber
                self.orderNumber+=1
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
        categoryArray = categoryArray?.sorted(byKeyPath: "order", ascending: true)
      
        cell.textLabel?.text=categoryArray?[indexPath.row].name ?? "No Categories Added"
       
        cell.backgroundColor=UIColor(hexString: categoryArray?[indexPath.row].backgroundColor ?? "ffffff")
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryArray?[indexPath.row].backgroundColor ?? "ffffff")!, returnFlat: true)
        cell.accessoryType = .disclosureIndicator;
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
        if segue.identifier=="colorSegue" {
            let destinationVC=segue.destination as! colorViewController
            print("helo")
            destinationVC.delegate=self
            destinationVC.path=changeColorIndexPath
            
            
        }
        
    }
    override func addAction(indexPath: IndexPath) -> [SwipeAction] {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)
            
            
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
            let alert=UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let changeColorAction=UIAlertAction(title: "Change Color", style: .default) { (action) in
                self.changeColorIndexPath=indexPath
                self.performSegue(withIdentifier: "colorSegue", sender: self)
                
            }
            let changeNameAction=UIAlertAction(title: "Change Name", style: .default) { (action) in
                self.changeName(indexPath: indexPath);
            }
            let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
            alert.addAction(changeColorAction)
            alert.addAction(changeNameAction)
            alert.addAction(cancel)
            self.present(alert,animated: true,completion:nil)
            
            
            
        }
        
        editAction.image = UIImage(named: "edit-icon")
        editAction.backgroundColor = UIColor.lightGray
        
        return [deleteAction,editAction]
    }
    
    
    
    override func updateModel(at indexPath: IndexPath) {
        
                if let categoryForDeletion=self.categoryArray?[indexPath.row]{
                    for index in indexPath.row...self.categoryArray!.endIndex-1 {
                        let object = categoryArray![index]
                        object.order -= 1
                    }
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
    override func editName(indexPath: IndexPath,text:String) {
        if let categoryForEditing=self.categoryArray?[indexPath.row]{
            
            do{
                try realm.write {
                    categoryForEditing.name=text;
                    tableView.reloadData()
                }
            }catch{
                print("Error changing category name,\(error)")
            }
        }
    }
}

extension UIColor {
    
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var hexString: String {
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}



