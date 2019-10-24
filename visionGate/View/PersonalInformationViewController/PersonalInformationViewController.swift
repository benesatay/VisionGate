//
//  PersonalInformationViewController.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 5.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class PersonalInformationViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    var tokenPhotoList : Array<UIImage> = []
    var selectedEmployee: EmployeeModel?
    var imageArray = [UIImage]()
    var takePhoto = EmployeeArrayViewModel()
    
    @IBOutlet weak var personalImageScrollView: UIScrollView!
    @IBOutlet weak var personalIDLabel: UILabel!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var personalFullnameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personalImageScrollView.isPagingEnabled = true
        personalImageScrollView.delegate = self
        personalImageScrollView.isPagingEnabled = true
        personalImageScrollView.showsVerticalScrollIndicator = false
        personalImageScrollView.showsHorizontalScrollIndicator = false
        
        imageActivityIndicator.isHidden = false
        
        view.addSubview(personalImageScrollView)
        
        if let employee = selectedEmployee {
            let fullName = employee.name! + " " + employee.surname!
            
            DispatchQueue.main.async {
                self.personalIDLabel.text = String(employee.id ?? 0) + " -"
                self.personalFullnameLabel.text = fullName
            }
            
            employee.downloadImages(completionHandler: { (images) in
                
                DispatchQueue.main.async {
                    self.setupAlbum(withImages: images)
                    self.imageActivityIndicator.isHidden = true
                }
            })
        }
    }

    func setupAlbum(withImages images: [UIImage]) {
       
        for (index, image) in images.enumerated() {
            
            let imageView = UIImageView(image: image)
            
            let xPosition = UIScreen.main.bounds.width * CGFloat(index)
            imageView.frame = CGRect(x:xPosition,
                                     y:0,
                                     width:personalImageScrollView.frame.width,
                                     height:personalImageScrollView.frame.height)
            
            imageView.contentMode = .scaleAspectFit
            
            personalImageScrollView.contentSize.width = personalImageScrollView.frame.width * CGFloat(index + 1)
            personalImageScrollView.addSubview(imageView)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(PersonalInformationViewController.getAddedImage), name: NSNotification.Name(rawValue: "newImage"), object: nil)
//    }

    @objc func getAddedImage() {
        if let employee = selectedEmployee {
            employee.downloadImages(completionHandler: { (images) in

                DispatchQueue.main.async {

                    self.setupAlbum(withImages: images)
                    self.imageActivityIndicator.isHidden = true
                }
            })
        }
    }
    

    @IBAction func addPhotoButton(_ sender: Any) {
//        let destination = TakePhotoViewController(nibName: "TakePhotoViewController", bundle: nil)
//        self.navigationController?.pushViewController(destination, animated: true)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        tokenPhotoList.append(image)
        setupAlbum(withImages: [image])
        
        uploadImages(image: image, personId: selectedEmployee!.id!, fileIndex: self.tokenPhotoList.count)
    }
    
    func uploadImages(image:UIImage, personId:Int, fileIndex:Int){
        
        let params = ["employeeImageInsertRequest":""]
        let request : NSMutableURLRequest
        let boundary = "Boundary-\(UUID().uuidString)"
        print("boundary :",boundary)
        
        request = NSMutableURLRequest(url: NSURL(string: "...")! as URL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.httpMethod = "POST"
        request.httpBody = createBody(parameters: params,
                                      boundary: boundary,
                                      data: image.pngData()!,
                                      mimeType: "image/jpg",
                                      filename: "image.jpg")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard let data = data, error == nil else { return }
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    
                    print("json data",json)
                    
                    DispatchQueue.main.async {
                        let imageView = UIImageView()
                        
                        if (json["status"] as? Int) != nil {
                            
                            let alert = UIAlertController(title: "Sunucu Hatası!", message: "Göndermeye çalıştığınız fotoğrafın boyutu çok yüksek.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Kapat", style: .cancel, handler: nil))
                            
                            self.present(alert, animated: true)
                            
                        } else {
                            
                            self.tokenPhotoList.remove(at: 0)
                            self.personalImageScrollView.addSubview(imageView)
                            self.createPersonalImage(personId: self.selectedEmployee!.id!, url: json["url"]! as! String, thumbnailUrl: json["thumbnailUrl"]! as! String)
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }).resume()
    }
    
    func createPersonalImage(personId: Int, url: String, thumbnailUrl: String) {
        
        print("tokenphotolist: ",tokenPhotoList.count)
        
        //        if tokenPhotoList.count > 0 {
        //            uploadImages(image: tokenPhotoList[0], personId: selectedEmployee!.id!, fileIndex: tokenPhotoList.count)
        //        }
        
        let createImageEndpoint = baseURL.appending("...")
        
        guard let urlx = URL(string: createImageEndpoint) else { return }
        
        let parameters = ["url": url, "thumbnailUrl": thumbnailUrl] as [String : Any]
        var request = URLRequest(url: urlx)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }).resume()
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }

    
    
}

