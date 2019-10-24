//
//  EmployeeViewModel.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 3.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class EmployeeArrayViewModel {
    
    var employees: [EmployeeModel] = []
    var passedEmployees: [passedPersonal] = []
    var images = [UIImage]()
    
    func getEmployees(onSuccess: @escaping ([EmployeeModel]) -> Void, onError: @escaping (Error) -> Void) {
        
        let getEndpoint = baseURL.appending("/...")
        
        guard let url = URL(string:getEndpoint) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard data != nil else { return }
            do {
                let employeeArray = try JSONDecoder().decode([EmployeeModel].self, from: data!)
                print(employeeArray)
                self.employees = employeeArray
                onSuccess(employeeArray)
                
            } catch let error {
//                print(error.localizedDescription)
                onError(error)
            }
        }.resume()
    }
    
    func passedEmployee(onSuccess: @escaping ([passedPersonal]) -> Void, onError: @escaping (Error) -> Void) {
        let passedEndpoint = baseURL.appending("...")
        
        guard let url = URL(string: passedEndpoint) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard data != nil else { return }
            do {
                let passedArray = try JSONDecoder().decode([passedPersonal].self, from: data!)
                print(passedArray)
                self.passedEmployees = passedArray
                onSuccess(passedArray)
                
            } catch let error {
//                print(error.localizedDescription)
                onError(error)
                debugPrint(error)

            }
        }.resume()
    }
    
    func createPersonal(name: String, surname: String, completion: @escaping ([EmployeeModel]) -> Void) {
        
        let createEndpoint = baseURL.appending("...")
        
        // let imageList : [ImageModel] = []
        
        guard let url = URL(string: createEndpoint) else { return }
        let parameters = ["name" : name, "surname" : surname, "employeeImages":[]] as [String : Any]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else { return }
            
            self.getEmployees(onSuccess: { employees in
                
                completion(employees)
            }, onError: { _ in })
            
        }.resume()
    }

    func getTrainingNewModel(onSuccess: @escaping () -> Void) {
        let getTrainingEndpoint = baseURL.appending("...")
        
        var request = URLRequest(url: URL(string: getTrainingEndpoint)!)
        request.httpMethod = "GET"
        DispatchQueue.main.async {
            onSuccess()
        }
    }
    
    func setTrainingNewModel(mode: String, onSuccess: @escaping () -> Void) {
        let setTrainingEndpoint = baseURL.appending("...")
        
        var request = URLRequest(url: URL(string: setTrainingEndpoint)!)
        request.httpMethod = "POST"
        DispatchQueue.main.async {
            onSuccess()
        }
        
        }

    
    
    func deleteEmployee(withId personId: Int, completion: @escaping (Error?) -> Void) {
        
        let deleteEndpoint = baseURL.appending("...")
        
        var request = URLRequest(url: URL(string: deleteEndpoint)!)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            completion(error)
        }.resume()
    }
}


