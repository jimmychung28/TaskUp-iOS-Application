//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-17.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
class TodoListViewController: SwipeTableViewController{
    let realm = try! Realm()
    var todoItems:Results<Item>?
    var datePicker=UIDatePicker()
    var dateField:UITextField?
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory: Category? {
        didSet{
           loadItems()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=super.tableView(tableView, cellForRowAt: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy h:mm a"
        // Configure the cell...
        
        if let item=todoItems?[indexPath.row]{
            cell.textLabel?.text=item.title
            cell.detailTextLabel?.text=dateFormatter.string(from:datePicker.date)
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
                        newItem.dateCreated=Date()
                        newItem.dateDeadline=self.datePicker.date
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
               
            }
           
            self.tableView.reloadData()
        }
        let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField=alertTextField
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
            do{
                try realm.write {
                    realm.delete(item)
                }
            }catch{
                print("Error deleting item,\(error)")
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
