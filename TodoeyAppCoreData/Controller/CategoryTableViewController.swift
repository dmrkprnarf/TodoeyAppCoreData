//
//  CategoryTableViewController.swift
//  TodoeyAppCoreData
//
//  Created by Arif Demirkoparan on 25.02.2023.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categories = [Category]()
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarEdit()
        load()
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print(urls!)
    }
    
    func navigationBarEdit() {
        let apperance = UINavigationBarAppearance()
        apperance.backgroundColor = UIColor.red
        apperance.titleTextAttributes = [
            .font:UIFont(name: "MuktaMahee Regular", size: 25)!,
            .foregroundColor:UIColor.white,]
        self.navigationController?.navigationBar.scrollEdgeAppearance = apperance
    }
    func save() {
        do {
            try context.save()
        }catch{
            print("Error\(error.localizedDescription)")
        }
    }
    
    func load(){
      let  request:NSFetchRequest<Category> = Category.fetchRequest()
      let sorted = NSSortDescriptor(key: "categoryDate", ascending: true)
      request.sortDescriptors = [sorted]
        do{
            categories = try context.fetch(request)
        }catch {
            print("Error\(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func attributeString(_ text:String,fontSize:CGFloat, _ color:UIColor) -> NSAttributedString {
        let attributeString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor:color,
            .font:UIFont.boldSystemFont(ofSize: fontSize)])
        return attributeString
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let title:String = "Add New Category "
        let message:String = ""
        var textfiled = UITextField()
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addTextField { addTextfield in
        textfiled = addTextfield
        }
        let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
            self.dismiss(animated: true)
        }
        let button = UIAlertAction(title: "Add", style: .default) { addButton in
            let categories = Category(context: self.context)
            if let text = textfiled.text {
                categories.name = text
                categories.categoryDate = Date()
            }
            self.categories.append(categories)
            self.save()
            self.tableView.reloadData()
        }
        alert.setValue(attributeString(title, fontSize: 15, .brown), forKey: "attributedTitle")
        alert.addAction(backButton)
        alert.addAction(button)
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var context = cell.defaultContentConfiguration()
        context.text = categories[indexPath.row].name
        context.textProperties.font = UIFont(name: "MuktaMahee Regular", size: 20)!
        cell.contentConfiguration = context
        return cell
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: {action,view,bool  in
            let category =  self.categories[indexPath.row]
            self.context.delete(category)
            self.categories.remove(at: indexPath.row)
            self.save()
            self.tableView.reloadData()
        })
        
        let update = UIContextualAction(style: .normal, title: "Update", handler: {updateAction,updateActionView,updateActionBool in
             var textfiled = UITextField()
            let alert = UIAlertController(title: "Update Category Item", message: "", preferredStyle: .alert)
            alert.addTextField { updateTextfiled in
                textfiled = updateTextfiled
            }
            let updateButton = UIAlertAction(title: "Update", style: .default) { updateButton in
                self.categories[indexPath.row].name = textfiled.text!
                self.categories[indexPath.row].categoryDate = Date()
                do {
                    try self.context.save()
                  
                }catch{
                    print("Error Update Category Item \(error.localizedDescription)")
                }
                tableView.reloadData()
            }
            alert.addAction(updateButton)
            self.present(alert, animated: true)
        })
        let swipe = UISwipeActionsConfiguration(actions: [delete,update])
        return swipe
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categories[indexPath.row]
        
        }
      
    }
    

}
