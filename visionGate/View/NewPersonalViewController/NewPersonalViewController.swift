//
//  NewPersonalViewController.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 7.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

//protocol NewPersonalViewControllerDelegate:class {
//    func didCreatePersonal(withEmployee employees: [EmployeeModel])
//}

//protocol addNewPersonalDelegate: class {
//    func didCreatePersonal(withEmployee employees: [EmployeeModel])
//}



class NewPersonalViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let reload = EmployeesViewController()
    let newEmp = EmployeeArrayViewModel()
    var selectedEmployee: EmployeeModel?
    var tokenPhotoList : Array<UIImage> = []
    
//    weak var delegate: NewPersonalViewControllerDelegate?
//    weak var delegate: addNewPersonalDelegate?
    
    @IBOutlet weak var companyLogoImageView: UIImageView!
    @IBOutlet weak var nameText: UITextField! = nil
    @IBOutlet weak var surnameText: UITextField! = nil
    @IBOutlet weak var takePhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.delegate = self
        surnameText.delegate = self
    }
    
    @IBAction func addNewPersonalButton(_ sender: Any) {
        
        newEmp.createPersonal(name: self.nameText.text!,
                              surname: self.surnameText.text!,
                              completion: { (employees) in
//                                self.delegate?.didCreatePersonal(withEmployee: emplooyes)
                    NotificationCenter.default.post(name: NSNotification.Name("newPersonal"), object: nil)

        })
        self.navigationController?.popViewController(animated: true)

    }
    
    //function of hiding keyboard after editing textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
