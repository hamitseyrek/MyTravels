//
//  ViewController.swift
//  MyTravels
//
//  Created by Hamit Seyrek on 18.01.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        getData()
        //navigator configuration
        navigationItem.title = "My Travels"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        //coreData
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlaceAdded"), object: nil)
    }
    
    
    @objc func addButtonClicked(){
        selectedID = nil
        performSegue(withIdentifier: "toMapVCS", sender: nil)
    }
    
    //TableView configuration
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    //CoreData
    @objc func getData() {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyPlaces")
        fetchRequest.returnsObjectsAsFaults = false // use cache
        do {
            let results =  try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("There is an error")
        }
        
    }
    
    // view or new
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVCS" {
            let destinationVC = segue.destination as! MapVC
            destinationVC.selectedID = selectedID
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = idArray[indexPath.row]
        performSegue(withIdentifier: "toMapVCS", sender: nil)
    }
    
    //Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetshRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyPlaces")
        let idString = idArray[indexPath.row].uuidString
        fetshRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetshRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetshRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID{
                        if id == idArray[indexPath.row]{
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            do {
                                try context.save()
                                break
                            }catch {
                                print("There is an error here 5")
                            }
                        }
                    }
                }
            }
        }catch{
            print("There is an error here3")
        }
    }
}
