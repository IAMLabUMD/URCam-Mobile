//
//  HTTPController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/23/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

class HTTPController {
    
    let url = URL(string: "http://128.8.235.4/TOR_app/db_command.php")!
    //let url = URL(string: "http://128.8.224.124:5000")!
    let boundary = "Boundary-\(UUID().uuidString)"
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
        //        formatter.dateFormat = "yyyy-MM-dd"
        
        let myString = formatter.string(from: date) // string purpose I add here
        return myString
    }
    
    func paramData(name: String, value: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(value)\r\n".data(using: .utf8)!)
        return body
    }
    
    func checkIsTraining(postProcessing: @escaping (String)->Void) {
        print("request-isTraining")
        Log.writeToLog("\(Actions.checkTraining.rawValue)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "isTraining"))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            //### Use `String` rather than `NSString` in Swift.
            let dataString = String(data: data, encoding: .utf8) ?? "request failed"
            print(dataString)
            
            DispatchQueue.main.async {
                postProcessing(dataString)
            }
        }
        task.resume()
    }
    
    func requestRecognition(capturedImg: UIImage, postProcessing: @escaping (String)->Void) {
        
        Log.writeToLog("\(Actions.recognitionBegan.rawValue)")
        
        let fname = "\(ParticipantViewController.mode)-\(formatDate(date: Date())).jpg"
        let mimetype = "image/jpg"
        
        print(fname)
        //### Use `URLRequest` rather than `NSMutableURLRequest` in Swift.
        //### Please do not miss, it's `var` not `let`.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = UIImageJPEGRepresentation(capturedImg, 1.0) //make
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "test-URCam"))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition:form-data; name=\"imgfile\"; filename=\"\(fname)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        //### No need to cast, when you use `Data`.
        request.httpBody = body
        
        //### No need to cast, when you use `URLRequest`.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                Log.writeToLog("\(Actions.recognitionSuccessful.rawValue)false")
                postProcessing("Error")
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Recognition failed."
            DispatchQueue.main.async {
                postProcessing(dataString)
                Log.writeToLog("RecognitionResult,\(fname),\(dataString)")
            }
        }
        task.resume()
    }
    
    func reqeustTrain_old(postProcessing: @escaping ()->Void) {
        simpleRequest(type: "trainRequest", postProcessing: postProcessing)
    }
    
    func requestRemove(_ object_to_remove: String, postProcessing: @escaping ()->Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "remove"))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append(paramData(name: "object_to_remove", value: object_to_remove))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            //### Use `String` rather than `NSString` in Swift.
            let dataString = String(data: data, encoding: .utf8) ?? "Undecodable result"
            
            //### Supplying default value prevents output "Optional(...)".
            print(dataString)
            
            DispatchQueue.main.async {
                postProcessing()
                Log.writeToLog("action= deleted_object: \(object_to_remove)")
            }
        }
        task.resume()
    }
    
    func requestRename(org_name: String, new_name: String, postProcessing: @escaping ()->Void) {
        print("requestRename-\(org_name)-\(new_name)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "rename"))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append(paramData(name: "org_name", value: org_name))
        body.append(paramData(name: "new_name", value: new_name))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            //### Use `String` rather than `NSString` in Swift.
            let dataString = String(data: data, encoding: .utf8) ?? "request failed"
            print(dataString)
            
            DispatchQueue.main.async {
                postProcessing()
                Log.writeToLog("action= renamed_object_to: \(new_name)")
            }
        }
        task.resume()
    }
    
    func requestRollback(postProcessing: @escaping ()->Void) {
        simpleRequest(type: "rollback", postProcessing: postProcessing)
    }
    
    // send a message with one command
    func simpleRequest(type: String, postProcessing: @escaping ()->Void) {
        print("request-\(type)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: type))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            //### Use `String` rather than `NSString` in Swift.
            let dataString = String(data: data, encoding: .utf8) ?? "request failed"
            print(dataString)
            
            DispatchQueue.main.async {
                postProcessing()
            }
        }
        task.resume()
    }
    
    // MARK: - TODO: Update userID to userUID generated for each unique user
    func syncRequest(items: String, postProcessing: @escaping (String)->Void) {
        print("request-sync")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "sync"))
        body.append(paramData(name: "items", value: items))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            //### Use `String` rather than `NSString` in Swift.
            let dataString = String(data: data, encoding: .utf8) ?? "request failed"
            print(dataString)
            
            DispatchQueue.main.async {
                postProcessing(dataString)
            }
        }
        task.resume()
    }
    
    /*
        Send text and a file to the server.
        Arguments:
            params: Dictionary with parameters (name:value)
            file: Data from a file (e.g., image, audio). The name of the file and the mimetype should be given in the params dictionary with 'fname' and 'mimetype' as keys.
            postProcessing: A function that is called when the response from the server is received.
     
        Return:
            N/A
     */
    func sendMessage(params: [String: String], file_data: Data?, postProcessing: @escaping (String)->Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName)) // userId and category are always sent
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        for (pname, pvalue) in params {
            body.append(paramData(name: pname, value: pvalue))
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        if params["fname"] != nil && params["mimetype"] != nil{
            body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(params["fname"]!)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(params["mimetype"]!)\r\n\r\n".data(using: .utf8)!)
            body.append(file_data!)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        }
        
        request.httpBody = body
        
        //### No need to cast, when you use `URLRequest`.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Undecodable result"
            print("Successfully sent to server. \(params)")
            
            DispatchQueue.main.async {
                postProcessing(dataString)
            }
        }
        task.resume()
    }
    
    func reqeustTrain_deprecated(postProcessing: @escaping (String)->Void) {
        Log.writeToLog("RequestTrain")
        
        let params = [
            "type": "trainRequest"
        ]
        sendMessage(params: params, file_data: nil, postProcessing: postProcessing)
    }
    
    func reqeustTrain(train_id: String, object_name: String, postProcessing: @escaping (String)->Void) {
        Log.writeToLog("RequestTrain")
        
        let params = [
            "type": "trainRequest",
            "train_id": "\(train_id)",
            "object_name": object_name
        ]
        sendMessage(params: params, file_data: nil, postProcessing: postProcessing)
    }
    
    func reqeustReset(postProcessing: @escaping (String)->Void) {
        Log.writeToLog("RequestReset")
        
        let params = [
            "type": "Reset"
        ]
        sendMessage(params: params, file_data: nil, postProcessing: postProcessing)
    }
    
    // get descriptors of a set of images
    func getSetDescriptor(obj_name: String, postProcessing: @escaping (String)->Void) {
        Log.writeToLog("\(Actions.getSetDescriptor.rawValue)")
        
        let params = [
            "type": "getSetDescriptor",
            "object_name": obj_name
        ]
        sendMessage(params: params, file_data: nil, postProcessing: postProcessing)
    }
    
    // get descriptors of a set of images
    func getSetDescriptorForReview(train_id: String, postProcessing: @escaping (String)->Void) {
        Log.writeToLog("getSetDescriptorForReview")
        
        let filePath = Log.userDirectory.appendingPathComponent("desc_info.txt")
        if let desc_data = FileManager.default.contents(atPath: filePath.path) {
            let params = [
                "type": "getSetDescriptorForReview",
                "fname": "desc_info-\(train_id).txt",
                "mimetype": "txt/csv"
            ]
            sendMessage(params: params, file_data: desc_data, postProcessing: postProcessing)
        }
    }
    
    // send the current image to generate image descriptors
    func getImgDescriptor(image: UIImage, index: Int, object_name: String, postProcessing: @escaping (String)->Void) {
        Log.writeToLog("\(Actions.getImageDescriptor.rawValue)")
        
        let image_data = UIImageJPEGRepresentation(image, 0.5)
        if image_data == nil {
            print("Image data was nil in sendImage to server.")
        } else {
            print("We is good for sendImage to server")
        }
        
        let params = [
            "type": "getImgDescriptor",
            "object_name": object_name,
            "fname": "\(index).jpg",
            "mimetype": "image/jpg"
        ]
        sendMessage(params: params, file_data: image_data!, postProcessing: postProcessing)
    }
    
    func sendARInfo(object_name: String, postProcessing: @escaping (String)->Void) {
        Log.writeToLog("sendARInfo")
        let filePath = Log.userDirectory.appendingPathComponent("desc_info.txt")
        
        if let desc_data = FileManager.default.contents(atPath: filePath.path) {
            let params = [
                "type": "ARInfoFile",
                "object_name": object_name,
                "fname": "desc_info.txt",
                "mimetype": "txt/csv"
            ]
            sendMessage(params: params, file_data: desc_data, postProcessing: postProcessing)
        }
    }
    
    // this function is deprecated.
    // Use sendImage(object_name: String, index: Int, image: UIImage, postProcessing: @escaping ()->Void)
    func sendImage(object_name: String, index: Int, image: UIImage, postProcessing: @escaping ()->Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //let imgPath = userDirectory.appendingPathComponent("\(object_name)/\(index).jpg")
        let image_data = UIImageJPEGRepresentation(image, 0.5)
        if image_data == nil {
            print("Image data was nil in sendImage to server.")
        } else {
            print("We is good for sendImage to server")
        }
        
        let fname = "\(index).jpg"
        let mimetype = "image/jpg"
        
        var body = Data()
        body.append(paramData(name: "userId", value: ParticipantViewController.userName))
        body.append(paramData(name: "type", value: "saveTrainPhoto"))
        body.append(paramData(name: "category", value: ParticipantViewController.category))
        body.append(paramData(name: "object_name", value: object_name))
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition:form-data; name=\"imgfile\"; filename=\"\(fname)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        //### No need to cast, when you use `URLRequest`.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, response != nil, error == nil else {
                print("error")
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Undecodable result"
            print("\(index) "+dataString)
            print("Successfully uploaded to server")
            
            DispatchQueue.main.async {
                postProcessing()
            }
        }
        task.resume()
    }
    
}
