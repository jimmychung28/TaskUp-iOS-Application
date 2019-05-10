//
//  TodoListViewController.swift
//
//  Created by Jimmy Chung on 2019-04-17.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import UserNotifications
import SwipeCellKit
class TodoListViewController: SwipeTableViewController{
    let realm = try! Realm()
    var todoItems:Results<Item>?
    var textField=UITextField()
    var orderNumber=0;
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var center:UNUserNotificationCenter?
    var selectedCategory: Category? {
        didSet{
           loadItems()
        }
    }
  
    
    @IBAction func rearrangeButton(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing
        if (editButton.title=="Done"){
            editButton.title="Rearrange"
            editButton.style = .plain
        }else{
            editButton.title="Done"
            editButton.style = .done
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
  
       
       
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let colour=selectedCategory?.backgroundColor else{fatalError()}
       
        updateNavBar(withHexCode: colour)
        title=selectedCategory?.name
          
        
    }
    override func addAction(indexPath: IndexPath) -> [SwipeAction] {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)
            
            
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
            let alert=UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
            let changeNameAction=UIAlertAction(title: "Change Name", style: .default) { (action) in
                self.changeName(indexPath: indexPath);
            }
            let changeDateAction=UIAlertAction(title: "Change Date", style: .default) { (action) in
                self.changeDate(indexPath:indexPath)
            }
            
         
            alert.addAction(changeNameAction)
            alert.addAction(changeDateAction)
            alert.addAction(cancel)
            self.present(alert,animated: true,completion:nil)
            
            
            
        }
        
        editAction.image = UIImage(named: "edit-icon")
        editAction.backgroundColor = UIColor.lightGray
        
        return [deleteAction,editAction]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
  
        updateNavBar(withHexCode: "1D9BF6")
    }

    // MARK: - Table view data source
    func updateNavBar(withHexCode colourHexCode:String){
        guard let navBar=navigationController?.navigationBar else{fatalError("No navigation controller")}
        guard let navBarColour=UIColor(hexString:colourHexCode)else{fatalError()}
        navBar.barTintColor=navBarColour
        navBar.tintColor=ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes=[NSAttributedString.Key.foregroundColor:ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor=navBarColour
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=super.tableView(tableView, cellForRowAt: indexPath)
         todoItems=todoItems?.sorted(byKeyPath: "order", ascending: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy h:mm a"
        // Configure the cell...
        cell.textLabel?.minimumScaleFactor=0.5
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if let item=todoItems?[indexPath.row]{
            cell.textLabel?.text=item.title
             cell.detailTextLabel?.text=nil
            if let deadline=item.dateDeadline{
                cell.detailTextLabel?.text=dateFormatter.string(from:deadline)
            }
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.textLabel!.text!)
            if item.done == true {
                cell.accessoryType = .checkmark
                 attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.textLabel?.attributedText=attributeString
                cell.detailTextLabel?.text=nil
            }else if item.done == false{
                cell.accessoryType = .none
                attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
                cell.textLabel?.attributedText=attributeString
            }
       
            if let colour=UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: 0.7*(CGFloat(indexPath.row)/CGFloat(todoItems!.count))){
                cell.backgroundColor=colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.detailTextLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
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
                if let id=item.notificationID{
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                }
            }catch{
                print("Error saving done status \(error)")
            }
           
        }

          tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
      
    }
   //Mark - Notification
    func addNotification(identifier: String){
        let notification=UNMutableNotificationContent()
        notification.title=textField.text!
        let dateComponents=Calendar.current.dateComponents(([.year,.month,.day,.hour,.minute]), from: self.datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        self.center?.add(request, withCompletionHandler: { (error) in })
    }

 //Mark - Add New Items


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert=UIAlertController(title: "Add new TaskUp Item", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Task", style: .default) { (action) in
            if let currentCategory=self.selectedCategory{
                do{
                    try self.realm.write {
                        if self.textField.text?.trimmingCharacters(in: .whitespaces).isEmpty != true{
                        let newItem=Item()
                        newItem.title=self.textField.text!
                        newItem.dateCreated=Date()
                        newItem.order=self.orderNumber
                        self.orderNumber+=1
                        if self.dateField?.text?.isEmpty != true{
                            newItem.dateDeadline=self.datePicker.date
                            let notificationIdentifier=UUID().uuidString
                            newItem.notificationID=notificationIdentifier
                            self.addNotification(identifier: notificationIdentifier)
                        }else {
                            newItem.dateDeadline=nil
                          
                        }
                        
                        currentCategory.items.append(newItem)
                    }
                    }
                }catch{
                    print("Error saving new Task, \(error)")
                }
                self.tableView.reloadData()
                
            }
           
            self.tableView.reloadData()
        }
        let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            self.textField=alertTextField
        }
        alert.addTextField { (alertDateField) in
            alertDateField.placeholder = "Date to complete task"
            self.datePicker.datePickerMode = .dateAndTime
            self.dateField=alertDateField
            
            alertDateField.inputView = self.datePicker
            self.datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        }
       
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
    }
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
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
                let sourceObject = todoItems![sourceIndexPath.row]
                let destinationObject = todoItems![destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.order
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let object = todoItems![index]
                        object.order -= 1
                    }
                } else {
                    
                    for index in (destinationIndexPath.row..<sourceIndexPath.row){
                        let object = todoItems![index]
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
    
    let datePicker=UIDatePicker()
    var dateField: UITextField?
    
    func changeDate(indexPath:IndexPath){
        let alert=UIAlertController(title: "Change Date:", message: nil, preferredStyle: .alert)
        let action=UIAlertAction(title: "Confirm", style: .default) { (action) in
            do{
                try self.realm.write {
                    if let id=self.todoItems![indexPath.row].notificationID{
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    }
                    if self.dateField?.text?.isEmpty != true{
                        self.todoItems![indexPath.row].dateDeadline=self.datePicker.date
                        let notificationIdentifier=UUID().uuidString
                        self.todoItems![indexPath.row].notificationID=notificationIdentifier
                        self.addNotification(identifier: notificationIdentifier)
                    }else {
                        self.todoItems![indexPath.row].dateDeadline=nil
                        
                    }
                }
            }catch{
                print("Error saving new Task, \(error)")
            }
           self.tableView.reloadData()
        }
       
        alert.addTextField { (alertDateField) in
            alertDateField.placeholder = "New Date to complete task"
            self.datePicker.datePickerMode = .dateAndTime
            self.dateField=alertDateField
            
            alertDateField.inputView = self.datePicker
            self.datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        }
        let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil);
        
    }
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy h:mm a"
        
        dateField?.text=dateFormatter.string(from:datePicker.date)
        view.endEditing(true)
    }
   
    

    func loadItems(){
        todoItems=selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
      }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item=todoItems?[indexPath.row]{
            
            if let id=item.notificationID {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            }
            do{
                try realm.write {
                    for index in indexPath.row...self.todoItems!.endIndex-1 {
                        let object = todoItems![index]
                        object.order -= 1
                    }
                    realm.delete(item)
                }
            }catch{
                print("Error deleting item,\(error)")
            }
        }
    }
    
    override func editName(indexPath: IndexPath,text:String) {
        if let itemForEditing=self.todoItems?[indexPath.row]{
            
            do{
                try realm.write {
                    itemForEditing.title=text;
                    tableView.reloadData()
                }
            }catch{
                print("Error changing item name,\(error)")
            }
        }
    }

}

extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems=todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
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
