//
//  ListTableViewController.swift
//  TodoeyAppCoreData
//
//  Created by Arif Demirkoparan on 26.02.2023.
//

import UIKit
import CoreData
class ListTableViewController: UITableViewController {
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var list = [Item]()
    var selectedCategory:Category? {
        didSet{
           load()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       load()
    }

    func save() {
        do {
            try context.save()
        }catch{
            print("Error\(error.localizedDescription)")
        }
    }
    
    func load(){
        let  request:NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        let sorted = NSSortDescriptor(key: "itemDate", ascending: true)
        request.predicate = categoryPredicate
        request.sortDescriptors = [sorted]
        do{
            list = try context.fetch(request)
        }catch {
            print("Error\(error.localizedDescription)")
        }
    }
    
     func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfiled = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        alert.addTextField { addTextfiled in
            textfiled = addTextfiled
        }
        let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
            self.dismiss(animated: true)
        }
        let button = UIAlertAction(title: "Add", style: .default) { buttonAction in
            let item = Item(context: self.context)
            if let text = textfiled.text {
                item.listName = text
                item.itemDate = Date()
                item.parentCategory = self.selectedCategory
               
            }
            self.list.append(item)
            self.save()
            self.tableView.reloadData()
           
        }
        alert.addAction(backButton)
        alert.addAction(button)
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        let list = list[indexPath.row]
        var context = cell.defaultContentConfiguration()
        context.text = list.listName
        cell.accessoryType = list.done == true ? .checkmark:.none
        cell.contentConfiguration = context
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = list[indexPath.row]
        list.done = !list.done
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let update = UIContextualAction(style: .normal, title: "Update", handler: {upAction,upView,upBool in
            var textfiled = UITextField()
            let alert = UIAlertController(title: "Update Item", message: "", preferredStyle: .alert)
            alert.addTextField { updateListTextfiled in
                textfiled = updateListTextfiled
            }
            let updateListButton = UIAlertAction(title: "Update", style: .default) { updateListbutton in
                self.list[indexPath.row].listName = textfiled.text!
                do {
                    try self.context.save()
                }catch{
                    print("Update Error Items \(error.localizedDescription)")
                }
                tableView.reloadData()
            }
            alert.addAction(updateListButton)
            self.present(alert, animated: true)
        })
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: {delAction,delView,delBool in
            let deleteItems =  self.list[indexPath.row]
            self.context.delete(deleteItems)
            self.list.remove(at: indexPath.row)
            do {
               try self.context.save()
            }catch{
                print("error\(error.localizedDescription)")
            }
            tableView.reloadData()
            
        })
        let swipe = UISwipeActionsConfiguration(actions:[delete,update,])
        return swipe
    }
}



