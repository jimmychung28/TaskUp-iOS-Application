//
//  SwipeTableViewController.swift
//
//  Created by Jimmy Chung on 2019-04-21.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import SwipeCellKit
import UserNotifications
class SwipeTableViewController: UITableViewController,SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
         tableView.rowHeight=80.0
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        return addAction(indexPath: indexPath)
    }
    func addAction(indexPath: IndexPath)->[SwipeAction]{
        return []
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

    func changeName(indexPath: IndexPath){
        var textField=UITextField();
        let alert=UIAlertController(title: "Change Name:", message: nil, preferredStyle: .alert)
        let action=UIAlertAction(title: "Confirm", style: .default) { (action) in
            if textField.text?.trimmingCharacters(in: .whitespaces).isEmpty != true{
                let text=textField.text
                self.editName(indexPath: indexPath,text:text!)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="New name"
            textField=alertTextField
        }
        let cancel=UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in})
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil);
    }
   
    func updateModel(at indexPath: IndexPath){
        
    }
    func editName(indexPath: IndexPath, text: String){
        
    }
}


