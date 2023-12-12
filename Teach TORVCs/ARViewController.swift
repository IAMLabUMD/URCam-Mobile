//
//  ARViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 1/5/21.
//  Copyright © 2021 Jaina Gandhi. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation
import MediaPlayer //Only for hidding  Volume view
import ARKit

@available(iOS 12.0, *)
class ARViewController: UIViewController, AVAudioPlayerDelegate, ARSCNViewDelegate, ARSessionDelegate, UIDocumentPickerDelegate {

//    var guideText = "This is a screen for taking photos of the item. You need 30 photos of this item. You can take a photo by tapping on the 'take photo' button at the bottom center. The phone will vibrate everytime you take a photo. You will be notified when you take every 5 photos and when you finished taking photos. Tap on any part of the screen to start."
    var guideText = "You can teach TOR to recognize an item by taking 30 photos of the item. TOR works best when you capture the object with lot of variations and angles."
    var olView: UIView!
    @IBOutlet weak var captureView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var arSceneView: ARSCNView!
    @IBOutlet weak var debugView: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var photoAttrView: UIView!
    
    var videoCapture: VideoCapture!
    var device: MTLDevice!
    let semaphore = DispatchSemaphore(value: 2)
    var capturedImg: UIImage?
    var currImg: UIImage?
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    var object_name = "tmpobj"
    var count = 0
    var attributes = ["• Hand in photo", "• Cropped object", "• Blurry", "• Small object"]
    
    var httpController = HTTPController()
    
    var detections = 0
    var lastDetectionDelayInSeconds: Double = 0
    var averageDetectionDelayInSeconds: Double = 0
    private var lastDetectionStartTime: Date?
    var noDetectionTimer: Timer?
    
    internal var screenCenter = CGPoint()
    var start_time = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ARViewController: \(ParticipantViewController.userName) \(ParticipantViewController.category) \(object_name) \(ParticipantViewController.itemNum)")
        
        //setUpCamera()
        createDirectory(object_name)
        
        // set-up AR scene view
        arSceneView.delegate = self
        arSceneView.session.delegate = self

        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // add overlay
        if ParticipantViewController.VisitedCameraView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedCameraView = 1
            //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
            cameraButton.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
        } else {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, "Take \(ParticipantViewController.itemNum) photos of the new item.")
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.cameraButton)
            //UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,  self.cameraButton);
        }
        
        navigationItem.titleView = Functions.createHeaderView(title: "Teach TOR")
        photoAttrView.layer.cornerRadius = 12
        dismissButton.roundButton(withBackgroundColor: .clear, opacity: 0)
        
        var attrs = ""
        attributes.forEach({attrs += $0 + "\n"})
        textView.text = attrs
        
        // delete the existing descriptor file
        do {
            try FileManager.default.removeItem(at: Log.userDirectory.appendingPathComponent("desc_info.txt"))
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        
        // Create Date object
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
        start_time = formatter.string(from: date)
        
//        generateAndSaveMergedARObject()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.teachScreen.rawValue)")
        
        listenVolumeButton()
        count = 0
        //ParticipantViewController.writeLog("CameraView-\(object_name)")
        captureView.alpha = 0
        
        // set-up AR view
        initARScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.teachScreen.rawValue)")
    }
    
    @IBAction func handleDismissButton(_ sender: UIButton) {
        animateOut(view: photoAttrView)
    }
    
    func generateAndSaveMergedARObject() {
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ar_objects", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let obj_name1 = "Lays"
        let obj_name2 = "Cheetos"
        let obj_name3 = "Fritos"
        
        print("load objects")
        var o1 = [ARReferenceObject]()
        var o2 = [ARReferenceObject]()
        var o3 = [ARReferenceObject]()
        for obj in referenceObjects {
            if obj.name!.contains(obj_name1) {
                o1.append(obj)
            } else if obj.name!.contains(obj_name2) {
                o2.append(obj)
            } else if obj.name!.contains(obj_name3) {
                o3.append(obj)
            }
        }
        print("obj lists \(o1.count) \(o2.count) \(o3.count)")
            
        print("merge objects")
        let merged_o1 = mergeARObjects(obj_list: o1)
        let merged_o2 = mergeARObjects(obj_list: o2)
        let merged_o3 = mergeARObjects(obj_list: o3)
        
        print("save objects")
        saveARObject(obj: merged_o1, filename: "merged_\(obj_name1).arobject")
        saveARObject(obj: merged_o2, filename: "merged_\(obj_name2).arobject")
        saveARObject(obj: merged_o3, filename: "merged_\(obj_name3).arobject")
    }
    
    func saveARObject(obj: ARReferenceObject, filename: String) {
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try obj.export(to: url, previewImage: UIImage(named: "shutter"))
        } catch {
            print("Save merged object error: \(error).")
        }
    }
    
    func mergeARObjects(obj_list: [ARReferenceObject]) -> ARReferenceObject{
        var merged_obj = obj_list[0]
        for i in 1...obj_list.count-1 {
            do {
                merged_obj = try merged_obj.merging(obj_list[i])
            } catch {
                print("Merge error: \(error).")
            }
        }
        return merged_obj
    }
    
    func initARScene() {
        
        print("make config")
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ar_objects", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        var o1: ARReferenceObject?
        var o2: ARReferenceObject?
        var o3: ARReferenceObject?
        var obj_names = ["merged_Lays", "merged_Cheetos", "merged_Fritos"]
//        var obj_names = ["Cheetos1", "Fritos1", "Lays1"]
        for obj in referenceObjects {
            if obj.name! == obj_names[0] {
                o1 = obj
            }
            if obj.name! == obj_names[1] {
                o2 = obj
            }
            if obj.name! == obj_names[2] {
                o3 = obj
            }
        }
        
        configuration.detectionObjects = [o1!, o2!, o3!]
        
        arSceneView.session.run(configuration)
        initDetection()
    }
    
    
    func initDetection() {
        detections = 0
        lastDetectionDelayInSeconds = 0
        averageDetectionDelayInSeconds = 0
        
        self.lastDetectionStartTime = Date()
        
        startNoDetectionTimer()
    }
    
    func startNoDetectionTimer() {
        cancelNoDetectionTimer()
        noDetectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.cancelNoDetectionTimer()
            print("Unable to detect the object. Please point the device at the scanned object, rescan or add another scan of this object in the current environment.")
        }
    }
    
    func cancelNoDetectionTimer() {
        noDetectionTimer?.invalidate()
        noDetectionTimer = nil
    }
    
    var detectedObject: ARObjectAnchor?
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            let name = objectAnchor.referenceObject.name!
            print("object is detected \(name), \(detections)")
            
            detectedObject = objectAnchor
            successfulDetection(objectAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    var framecnt = 0
    var ar_side = "NoSide"
    var camera_position = (Float(0.0), Float(0.0), Float(0.0))
    var camera_orientation = (Float(0.0), Float(0.0), Float(0.0))
    var obj_position = (Float(0.0), Float(0.0), Float(0.0))
    var obj_orientation = (Float(0.0), Float(0.0), Float(0.0))
    var obj_cam_position = (Float(0.0), Float(0.0), Float(0.0))
    var cam_mat = simd_float4x4()
    var obj_mat = simd_float4x4()
    var cam_obj_mat = simd_float4x4()
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        framecnt += 1
        if framecnt >= 1000 {
            framecnt = 0
        }
        guard let currentFrame = session.currentFrame else { return }
        capturedImg = UIImage(ciImage: CIImage(cvPixelBuffer: currentFrame.capturedImage))
        ar_side = "NoSide"
        
        let ct = frame.camera.transform
        camera_position = (ct.columns.3.x, ct.columns.3.y, ct.columns.3.z)
        camera_orientation = (ct.columns.2.x, ct.columns.2.y, ct.columns.2.z)
        cam_mat = ct
        
//        let dt = String(format: "Camera position %7.2f %7.2f %7.2f", camera_position.0, camera_position.1, camera_position.2)
//        print(dt)
//        DispatchQueue.main.async {
//            self.debugView.text = dt
//        }
        
        //print("Session \(framecnt)")
        if let objTransform = detectedObject?.transform {
            obj_position = (objTransform.columns.3.x, objTransform.columns.3.y, objTransform.columns.3.z)
            obj_orientation = (objTransform.columns.2.x, objTransform.columns.2.y, objTransform.columns.2.z)
            obj_mat = objTransform
            
            let camMatObj = convertToObjCoord(cameraTransform: frame.camera.transform, objTransform: objTransform)
//            printMatrix(mat: camMatObj)
            cam_obj_mat = camMatObj
            
            ar_side = "top" // top, bottom, left, right, front, back
            let x = camMatObj.columns.3.x
            let y = camMatObj.columns.3.y
            let z = camMatObj.columns.3.z
            
            obj_cam_position = (x, y, z)
            
            let abs_x = abs(x)
            let abs_y = abs(y)
            let abs_z = abs(z)
            if abs_x > abs_y && abs_x > abs_z {
                if x > 0 {
                    ar_side = "front"
                } else {
                    ar_side = "back"
                }
            } else if abs_y > abs_x && abs_y > abs_z {
                if y > 0 {
                    ar_side = "top"
                } else {
                    ar_side = "bottom"
                }
            } else if abs_z > abs_x && abs_z > abs_y {
                if z > 0 {
                    ar_side = "left"
                } else {
                    ar_side = "right"
                }
            }
            
            let camPos = String(format: "%7.2f %7.2f %7.2f - \(ar_side)", x, y, z)
            print("Cam position: \(camPos) \(detectedObject?.name)")
        }
    }
    
    // about matrix
    // https://stackoverflow.com/questions/45437037/arkit-what-do-the-different-columns-in-transform-matrix-represent
    // https://stackoverflow.com/questions/59294602/how-do-i-rotate-an-object-around-only-one-axis-in-realitykit?noredirect=1&lq=1
    func printMatrix(mat: float4x4) {
        let tp_tr = mat.transpose
        let c1 = String(format: "%7.2f %7.2f %7.2f %7.2f", tp_tr.columns.0.x, tp_tr.columns.0.y, tp_tr.columns.0.z, tp_tr.columns.0.w)
        let c2 = String(format: "%7.2f %7.2f %7.2f %7.2f", tp_tr.columns.1.x, tp_tr.columns.1.y, tp_tr.columns.1.z, tp_tr.columns.1.w)
        let c3 = String(format: "%7.2f %7.2f %7.2f %7.2f", tp_tr.columns.2.x, tp_tr.columns.2.y, tp_tr.columns.2.z, tp_tr.columns.2.w)
        let c4 = String(format: "%7.2f %7.2f %7.2f %7.2f", tp_tr.columns.3.x, tp_tr.columns.3.y, tp_tr.columns.3.z, tp_tr.columns.3.w)
        
        print(c1)
        print(c2)
        print(c3)
        print(c4)
    }
    
    func convertToObjCoord(cameraTransform: float4x4, objTransform: float4x4) -> float4x4{
        // https://developer.apple.com/forums/thread/131982
        let cameraMatrix = SCNMatrix4.init(cameraTransform)
        let objMatrix = SCNMatrix4.init(objTransform)
        let objNode = SCNNode()
        objNode.transform = objMatrix
        let originNode = SCNNode()
        originNode.transform = SCNMatrix4Identity
        //Converts a transform from the node’s local coordinate space to that of another node.
        let transformInObjSpace = originNode.convertTransform(cameraMatrix, to: objNode)
        let cameraTransformFromObj = simd_float4x4(transformInObjSpace)
        return cameraTransformFromObj
    }
    
    func convertToCameraCoord(currTransform: float4x4, frame: ARFrame) -> float4x4{
        // https://developer.apple.com/forums/thread/131982
        let currentCameraTransform = frame.camera.transform
        let newFaceMatrix = SCNMatrix4.init(currTransform)
        let newCameraMatrix = SCNMatrix4.init(currentCameraTransform)
        let cameraNode = SCNNode()
        cameraNode.transform = newCameraMatrix
        let originNode = SCNNode()
        originNode.transform = SCNMatrix4Identity
        //Converts a transform from the node’s local coordinate space to that of another node.
        let transformInCameraSpace = originNode.convertTransform(newFaceMatrix, to: cameraNode)
        let faceTransformFromCamera = simd_float4x4(transformInCameraSpace)
        return faceTransformFromCamera
    }
    
    func cameraLocationOrientation() {
        // https://stackoverflow.com/questions/45084187/arkit-get-current-position-of-arcamera-in-a-scene
        guard let pointOfView = arSceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = SCNVector3(orientation.x + location.x, orientation.y + location.y, orientation.z + location.z)
        print(currentPositionOfCamera)
    }
    
    func successfulDetection(_ objectAnchor: ARObjectAnchor) {
        // Compute the time it took to detect this object & the average.
        lastDetectionDelayInSeconds = Date().timeIntervalSince(self.lastDetectionStartTime!)
        detections += 1
        averageDetectionDelayInSeconds = (averageDetectionDelayInSeconds * Double(detections - 1) + lastDetectionDelayInSeconds) / Double(detections)
                
        // Immediately remove the anchor from the session again to force a re-detection.
        self.lastDetectionStartTime = Date()
        self.arSceneView.session.remove(anchor: objectAnchor)
                
        startNoDetectionTimer()
    }
    
    private var audioLevel : Float = 0.0
    var volumeView = MPVolumeView(frame: CGRect(x: -100, y: 0, width: 0, height: 0))
    func listenVolumeButton(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, with: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            audioLevel = audioSession.outputVolume
            
            view.addSubview(volumeView)
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            if let view = volumeView.subviews.compactMap({ $0 as? UISlider }).first {
                view.value = Float(audioLevel) //---0 t0 1.0---
                //                view.setValue(audioLevel, animated: false)
            }
            
//            let audioSession = AVAudioSession.sharedInstance()
//            print(audioLevel, audioSession.outputVolume)
            
            ParticipantViewController.writeLog("volumeButton")
            takePhoto()
        }
    }
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // Step 2
        let path = CGMutablePath()
        //path.addArc(center: CGPoint(x: frame.midX, y: frame.midY), radius: radius1, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: frame.midX, y: frame.height), radius: 100, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = kCAFillRuleEvenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        // add text for guidance
        let label = UILabel(frame: CGRect(x:10, y:10, width: frame.size.width - 60, height: CGFloat(25)))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.white
        label.textAlignment = .left;
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        label.text = guideText
        label.accessibilityLabel = ""
        label.alpha = 1.0
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.frame.size.width = self.view.frame.size.width - 60
        label.isAccessibilityElement = false
        
        
        let labelContainer = UIView(frame: CGRect(x:20, y:frame.midY/3 - 10, width: frame.size.width - 40, height: label.frame.size.height + 20))
        labelContainer.layer.cornerRadius = 15
        labelContainer.layer.masksToBounds = true
        labelContainer.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        labelContainer.isAccessibilityElement = false
        labelContainer.addSubview(label)
        
        overlayView.addSubview(labelContainer)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.touchOverlay(_:)))
        overlayView.addGestureRecognizer(gesture)
        overlayView.isUserInteractionEnabled = true
        overlayView.accessibilityLabel = guideText
        overlayView.isAccessibilityElement = true
        
        return overlayView
    }
    
    // or for Swift 4
    @objc func touchOverlay(_ sender:UITapGestureRecognizer){
        // do other task
        ParticipantViewController.writeLog("CameraOverlayDismiss")
        
        cameraButton.accessibilityElementsHidden = false
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController)
        
        olView.removeFromSuperview()
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: - Animates a view in
    func animateIn(view: UIView) {
        
        self.view.addSubview(view)
        view.center = CGPoint(x: arSceneView.center.x, y: arSceneView.center.y - 54)
        view.alpha = 0
        view.transform = CGAffineTransform.init(translationX: 0, y: 40)
        
        UIView.animate(withDuration: 0.4) {
            view.transform = .identity
            view.alpha = 1
        }
        
        
        UIView.animate(withDuration: 0.4, animations: {
            
            view.transform = .identity
            view.alpha = 1
            
        }) { (_) in
            UIView.animate(withDuration: 0.4, delay: 0.8, animations: {
                view.alpha = 0
                view.transform = CGAffineTransform.init(translationX: 0, y: 40)
                
            }) { (_) in
                view.removeFromSuperview()
            }
        }
        
    }
    
    // MARK: - Animates a view out
    func animateOut(view: UIView) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            view.transform = CGAffineTransform.init(translationX: 0, y: 40)
            view.alpha = 0
            
        }) { (_) in
            
            view.removeFromSuperview()
        }
    }
    
    
    // MARK: - This functions animates a view that visually informs the user how many photos
    // MARK: - are left to be taken.
    func animateLabel(message: String, showSubtitle: Bool) {
        
        // Build the view with labels
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        bgView.backgroundColor = .clear
        
        let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 180))
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = .rounded(ofSize: 80, weight: .bold)
        
        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 249, height: 80))
        leftLabel.textColor = .white
        leftLabel.textAlignment = .center
        leftLabel.text = showSubtitle ? "left": ""
        leftLabel.font = .rounded(ofSize: 40, weight: .bold)
        
        bgView.addSubview(countLabel)
        countLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y - 48)
        
        bgView.addSubview(leftLabel)
        leftLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y + 24)
        
        
        countLabel.text = "\(message)"
        view.addSubview(bgView)
        bgView.center = CGPoint(x: arSceneView.center.x, y: arSceneView.center.y - 54)
        bgView.alpha = 0
        bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
        
        UIView.animate(withDuration: 0.6, animations: {
            
            bgView.transform = .identity
            bgView.alpha = 1
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.4, delay: 0.8, animations: {
                bgView.alpha = 0
                bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
                
            }) { (_) in
                bgView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func captureImage(_ sender: Any) {
        ParticipantViewController.writeLog("captureButton")
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) button=captureButton")
        takePhoto()
    }
    
    func takePhoto() {
        captureView.alpha = 1
        ParticipantViewController.writeLog("TakePhoto-\(object_name)-\(count+1)")
        Functions.startGyros(for: count+1)
        Log.writeToLog("\(Actions.photoTaken.rawValue) of \(object_name)-(\(count+1))")
        
        if count >= ParticipantViewController.itemNum {
            return
        }
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        playSound(name: "shutter")
        
        currImg = capturedImg!.rotate(radians: .pi/2) // Rotate 90 degrees
        captureView.image = currImg
        
        count = count + 1
        saveImage(count)
        let desc_info = "\(count)#\(self.ar_side)#" +
            "\(self.camera_position.0)#\(self.camera_position.1)#\(self.camera_position.2)#" +
            "\(self.camera_orientation.0)#\(self.camera_orientation.1)#\(self.camera_orientation.2)#" +
            "\(self.obj_position.0)#\(self.obj_position.1)#\(self.obj_position.2)#" +
            "\(self.obj_orientation.0)#\(self.obj_orientation.1)#\(self.obj_orientation.2)#" +
            "\(self.obj_cam_position.0)#\(self.obj_cam_position.1)#\(self.obj_cam_position.2)#" +
            "\(cam_mat)#\(obj_mat)#\(cam_obj_mat)"
        
        httpController.getImgDescriptor(image: currImg!, index: count, object_name: "Train-\(start_time)") {(response) in
            var resp = "NA"
            let output_components = response.components(separatedBy: "#")
            if output_components.count != 6 {
                print("The response is not valid. Response: \"\(response)\"...\(output_components.count)")
            } else {
                let hand = output_components[0]
                let blurry = output_components[1]
                let cropped = output_components[2]
                let small = output_components[3]
                
                DispatchQueue.main.async {
                    var attrs = ""
                    if hand == "True" {
                        attrs += self.attributes[0]+"\n"
                    }
                    if blurry == "True" {
                        attrs += self.attributes[2]+"\n"
                    }
                    if cropped == "True" {
                        attrs += self.attributes[1]+"\n"
                    }
                    if small == "True" {
                        attrs += self.attributes[3]+"\n"
                    }
                    self.textView.text = attrs
                    if attrs != "" {
                        self.textToSpeech(attrs.replacingOccurrences(of: "•", with: ""))
                        self.animateIn(view: self.photoAttrView)
                    }
                }
                resp = response
            }
            
            print(resp)
            self.writeDescInfo(line: "\(desc_info)#\(resp)")
            Log.writeToLog("\(desc_info)#\(resp)")
        }
        
        if count%5 == 0 {
            if count == ParticipantViewController.itemNum {
                //                textToSpeech("You finished taking 30 photos of \(object_name)")
                //showToast(message: "You finished taking 30 photos of \(object_name)")
            } else {
                //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "\(30-count) left")
                textToSpeech("\(ParticipantViewController.itemNum-count) left")
                animateLabel(message: "\(ParticipantViewController.itemNum-count)", showSubtitle: true)
            }
        }
        
    }
    
    
    
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    var player: AVAudioPlayer?
    func playSound(name: String){
        if player != nil {
            if player!.isPlaying {
                player?.stop()
            }
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func countSamples (_ label: String) -> Int {
        let imgPath = Log.userDirectory.appendingPathComponent("\(label)")
        let fileManager = FileManager.default
        
        var isDirectory = ObjCBool(true)
        if fileManager.fileExists(atPath: imgPath.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    let fileURLs = try fileManager.contentsOfDirectory(at: imgPath, includingPropertiesForKeys: nil)
                    // process files
                    return fileURLs.count
                } catch let error as NSError {
                    print("Error creating directory: \(error.localizedDescription)")
                }
            }
        }
        return -1
    }
    
    func createDirectory(_ label: String) {
        let classPath = Log.userDirectory.appendingPathComponent("\(label)")
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: classPath.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: classPath.path, withIntermediateDirectories: true, attributes: nil)
                print("directory is created. \(classPath.path)")
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    func saveImage(_ index: Int) {
        if captureView.image == nil { return }
        let imgPath = Log.userDirectory.appendingPathComponent("\(object_name)")
        
        // Save high-res photos to be sent to the server
        if let data = UIImageJPEGRepresentation(currImg!, 1.0) {
            let filename = imgPath.appendingPathComponent("\(index).jpg")
            try? data.write(to: filename)
            Log.writeToLog("action= High-res image \(index) of \(object_name) saved locally on device")
            print("The image is saved.\n\(filename)")
        }
        
        
        if index == ParticipantViewController.itemNum {
            textToSpeech("Done")
            animateLabel(message: "Done", showSubtitle: false)
            
            cameraButton.isEnabled = false
            cameraButton.isAccessibilityElement = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//                let vc = TrainingVC()
//                vc.objectName = "tmpobj"
//                self.navigationController?.pushViewController(vc, animated: true)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewTrainingVC") as! ReviewTrainingVC
                vc.item = Item(itemName: "New object", itemDate: "", relativeDate: "Now", image:"1")
                vc.train_id = "Train-\(self.start_time)"
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
        }
        
        print(countSamples(object_name))
    }
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    func textToSpeech(_ text: String) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        print("tts: \(text)")
        myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        myUtterance.volume = 1.0
        synth.speak(myUtterance)
    }
    
    //https://stackoverflow.com/questions/24097826/read-and-write-a-string-from-text-file
    func writeDescInfo(line: String) {
        // If the directory was found, we write a file to it and read it back
        let fileURL = Log.userDirectory.appendingPathComponent("desc_info.txt")
        do {
            try line.appendLineToURL(fileURL: fileURL as URL)
        } catch {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }

        // Then reading it back from the file
//        var inString = ""
//        do {
//            inString = try String(contentsOf: fileURL)
//        } catch {
//            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//        }
//        print("Read from the file: \(inString)")
    }
}


@available(iOS 12.0, *)
extension ARViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoTexture texture: MTLTexture?, timestamp: CMTime) {
        // For debugging.
        //predict(texture: loadTexture(named: "dog416.png")!); return
        // The semaphore is necessary because the call to predict() does not block.
        // If we _would_ be blocking, then AVCapture will automatically drop frames
        // that come in while we're still busy. But since we don't block, all these
        // new frames get scheduled to run in the future and we end up with a backlog
        // of unprocessed frames. So we're using the semaphore to block if predict()
        // is already processing 2 frames, and we wait until the first of those is
        // done. Any new frames that come in during that time will simply be dropped.
        
        capturedImg = capture.currImage
    }
    
    func videoCapture(_ capture: VideoCapture, didCapturePhotoTexture texture: MTLTexture?, previewImage: UIImage?) {
        // not implemented
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }

 extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }
