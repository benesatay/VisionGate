//
//  TakePhotoViewController.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 5.08.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    

    var tokenPhotoList : Array<UIImage> = []
    var selectedEmployee: EmployeeModel?

    @IBOutlet weak var tokenPhotoCollectionView: UICollectionView!
    @IBOutlet weak var selectedPhotoForUploadCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = tokenPhotoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        

        let nib = UINib(nibName: "TakePhotoCollectionViewCell", bundle: nil)
        tokenPhotoCollectionView.register(nib, forCellWithReuseIdentifier: "TakePhotoCollectionViewCell")
        selectedPhotoForUploadCollectionView.register(nib, forCellWithReuseIdentifier: "TakePhotoCollectionViewCell")
        
        DispatchQueue.main.async {
            self.selectedPhotoForUploadCollectionView.reloadData()
//            self.passedEmployeeActivityIndicator.isHidden = true
        }

        
    }

    @IBAction func selectPhotoButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoButton(_ sender: Any) {
        
        if tokenPhotoList.count > 0 {
            uploadImages(image: tokenPhotoList[0], personId: (selectedEmployee?.id!)!, fileIndex: self.tokenPhotoList.count)
            selectedPhotoForUploadCollectionView.isHidden = true
        }
    }
    
    @IBAction func takePhotoPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:tokenPhotoCollectionView.frame.width, height: tokenPhotoCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width:0.0, height: 0.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedPhotoForUploadCollectionView {
            return (selectedEmployee?.images!.count)!
        } else {
            return tokenPhotoList.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TakePhotoCollectionViewCell", for: indexPath) as! TakePhotoCollectionViewCell
        
//        if collectionView == selectedPhotoForUploadCollectionView {
//            cell.imageView.downloaded(from: "\(personAllData[0].images[indexPath.row].url)")
//        }
        cell.imageView.image = self.tokenPhotoList[indexPath.row]

        return cell
    }

    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        tokenPhotoList.append(image)
        selectedPhotoForUploadCollectionView.reloadData()
//        setupAlbum(withImages: [image])
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
                            self.selectedPhotoForUploadCollectionView.addSubview(imageView)
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

//extension NSMutableData {
//    func appendString(_ string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
//        append(data!)
//    }
//    
//    
//    
//}
