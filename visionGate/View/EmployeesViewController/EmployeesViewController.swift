//
//  EmployeesViewController.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 5.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class EmployeesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = EmployeeArrayViewModel()
    var selectedPersonal: EmployeeModel?
    
    @IBOutlet weak var solidLabel: UILabel!
    @IBOutlet weak var personalListTableView: UITableView!
    @IBOutlet weak var personalListActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personalListTableView.delegate = self
        personalListTableView.dataSource = self
        
        personalListActivityIndicator.isHidden = false
        
        //getEmployees()
        viewModel.getEmployees(onSuccess: { (employees) in
            DispatchQueue.main.async {
                self.personalListTableView.reloadData()
            self.personalListActivityIndicator.isHidden = true
            }
        }, onError: { error in
            print(error.localizedDescription)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(EmployeesViewController.getAddedPersonal), name: NSNotification.Name(rawValue: "newPersonal"), object: nil)
    }
    
    @objc func getAddedPersonal() {
        
        let alert = UIAlertController(title: "Başarılı", message: "Personel Eklendi!", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        
        self.personalListTableView.isHidden=true
        self.personalListActivityIndicator.isHidden = false

        viewModel.getEmployees(onSuccess: { (employees) in
            DispatchQueue.main.async {
                self.personalListTableView.reloadData()
                self.personalListTableView.isHidden=false
                self.personalListActivityIndicator.isHidden = true
                
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }, onError: { error in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func addNewPersonalButton(_ sender: Any) {
        let destination = NewPersonalViewController(nibName: "NewPersonalViewController", bundle: nil)
        //destination.delegate = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        let employee = viewModel.employees[indexPath.row]
        
        let fullName = (employee.name ?? "") + " " + (employee.surname ?? "")
        cell.textLabel?.text = "\(employee.id ?? 0) \("-") \(fullName)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.employees.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = PersonalInformationViewController(nibName: "PersonalInformationViewController", bundle: nil)
        
        selectedPersonal = viewModel.employees[indexPath.row]
        
        destination.selectedEmployee = self.selectedPersonal
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            guard let employeeId = viewModel.employees[indexPath.row].id else { return }
            viewModel.deleteEmployee (withId: employeeId, completion: { (error) in
                
                guard error == nil else { return }
                
                DispatchQueue.main.async {
                    self.viewModel.employees.remove(at: indexPath.row)
                    self.personalListTableView.beginUpdates()
                    self.personalListTableView.deleteRows(at: [indexPath], with: .fade)
                    self.personalListTableView.endUpdates()
                }
            })
        }
    }
}


//extension EmployeesViewController: NewPersonalViewControllerDelegate {
//
//    func didCreatePersonal(withEmployee employees: [EmployeeModel]) {
//
//       let lastItem =  employees.filter { emp in
//
//            return viewModel.employees.contains { $0.id == emp.id } == false
//        }.first!
//
//        viewModel.employees.append(lastItem)
//
////        print(lastItem.name)
//
//        let destination = PersonalInformationViewController(nibName: "PersonalInformationViewController", bundle: nil)
//        destination.selectedEmployee=lastItem
//        navigationController?.pushViewController(destination, animated: true)
//    }
//}





//extension EmployeesViewController: addNewPersonalDelegate {
//    func didCreatePersonal(withEmployee employees: [EmployeeModel]) {
//        self.personalListActivityIndicator.isHidden = false
//
//            viewModel.getEmployees(onSuccess: { (employees) in
//                    self.personalListTableView.reloadData()
//                    self.personalListActivityIndicator.isHidden = true
//
//            }, onError: { error in
//                print(error.localizedDescription)
//            })
//    }
//}
