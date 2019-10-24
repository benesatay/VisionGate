//
//  MainViewController.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 5.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func passgetTrainingMode(success: Bool) {
        EmployeeModel.currentTrainingMode = success
        if success == true {
            passedEmployeeCollectionView.isHidden = true
            passedEmployeeActivityIndicator.isHidden = false
        } else {
            passedEmployeeCollectionView.isHidden = false
            passedEmployeeActivityIndicator.isHidden = true
        }
    }
    
    func passGetAllPassing(passedPersonals: [passedPersonal]) {
        
        self.passedPersonals = passedPersonals
        
        if EmployeeModel.currentTrainingMode == false {
            passedEmployeeActivityIndicator.isHidden = true
            passedEmployeeCollectionView.isHidden = false
        }
        
        
        
        print("self.allPassing.count :",self.passedPersonals.count)
        self.passedPersonals.reverse()
        self.passedPersonals = self.passedPersonals.sorted(by: { UIContentSizeCategory(rawValue: $0.date!) > UIContentSizeCategory(rawValue: $1.date!) })
        
        passedEmployeeCollectionView.reloadData()
//        totalTime = 5
//        startTimer()
        viewModel.getTrainingNewModel(onSuccess: {})
        viewModel.getTrainingNewModel(onSuccess: {})
    }

    var passedPersonals : [passedPersonal] = []

    var viewModel = EmployeeArrayViewModel()

    @IBOutlet weak var passedEmployeeCollectionView: UICollectionView!
    @IBOutlet weak var passedEmployeeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyLogoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        passedEmployeeCollectionView.delegate = self
        passedEmployeeCollectionView.dataSource = self
        
        passedEmployeeActivityIndicator.isHidden = false

        if EmployeeModel.currentTrainingMode == false {
            passedEmployeeCollectionView.isHidden = false
//        passedEmployeeActivityIndicator.isHidden = true
            
        }
        
        let nib = UINib(nibName: "PassedPersonalCollectionViewCell", bundle: nil)
        passedEmployeeCollectionView.register(nib, forCellWithReuseIdentifier: "PassedPersonalCollectionViewCell")
        
        //passedEmployee()
        viewModel.passedEmployee(onSuccess: { (passedEmployees) in
            DispatchQueue.main.async {
                self.passedEmployeeCollectionView.reloadData()
                self.passedEmployeeActivityIndicator.isHidden = true
            }
        }, onError: { error in
            print(error.localizedDescription)
        })
    }

    @IBAction func trainNewModelButton(_ sender: Any) {
        viewModel.setTrainingNewModel(mode: "true", onSuccess: {
            self.passedEmployeeCollectionView.isHidden = true
        self.passedEmployeeActivityIndicator.isHidden = false
        })
    }
    
    @IBAction func personalListButton(_ sender: Any) {
        let destination = EmployeesViewController(nibName: "EmployeesViewController", bundle: nil)
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 320, height: 60)
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PassedPersonalCollectionViewCell", for: indexPath) as! PassedPersonalCollectionViewCell
        
        let passedPerson = viewModel.passedEmployees[indexPath.row]
        
        let fullName = (passedPerson.name!) + " " + (passedPerson.surname!)
   
        cell.passedNameLabel.text = "\(fullName)"
        cell.passingTimeLabel.text = "\(passedPerson.date!)"

        if passedPerson.entrance == true {
            cell.entranceImageView.image = UIImage.init(named: "entrance")
        } else {
            cell.entranceImageView.image = UIImage.init(named: "exit")
        }

        cell.passedPersonalImageView.image = convertStringToImage(base64string: passedPerson.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.passedEmployees.count
    }
    
    func convertStringToImage(base64string: String?) -> UIImage {
        
        if (base64string?.count)! < 200 {
            return #imageLiteral(resourceName: "profile")
        } else {
            var baseFinal = base64string!
            baseFinal.removeFirst()
            
            do {
                if let dataDecoded : Data = Data(base64Encoded: baseFinal, options: .ignoreUnknownCharacters) {
                    let decodedImage = UIImage(data: dataDecoded)
                    return decodedImage!
                }
            } catch let error {
                return #imageLiteral(resourceName: "profile")
            }
            
            return #imageLiteral(resourceName: "profile")
         
        }
    }
    
    
}
