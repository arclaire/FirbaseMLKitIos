//
//  ViewController.swift
//  FirbaseMLKitIos
//
//  Created by Lucy on 20/01/20.
//  Copyright © 2020 Lucy. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonPickImage: UIButton!
    let imagePicker = UIImagePickerController()
    
    let options = VisionFaceDetectorOptions()
    lazy var vision = Vision.vision()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.options.contourMode = .all
        self.options.landmarkMode = .all
        self.options.classificationMode = .all
        self.options.performanceMode = .accurate
        self.options.minFaceSize = CGFloat(0.1)
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func actionButton(_ sender: Any) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    
}


extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            let faceDetector = vision.faceDetector(options: options)
            let visionImage = VisionImage(image: pickedImage)
            faceDetector.process(visionImage) { faces, error in
              guard error == nil, let faces = faces, !faces.isEmpty else {
                print("NO FACEs")
                // ...
                return
              }

              // Faces detected
              // ...
                
                print("HAVE FACES", faces.count)
                for face in faces {
                  let frame = face.frame
                  if face.hasHeadEulerAngleY {
                    let rotY = face.headEulerAngleY  // Head is rotated to the right rotY degrees
                  }
                  if face.hasHeadEulerAngleZ {
                    let rotZ = face.headEulerAngleZ  // Head is rotated upward rotZ degrees
                  }

                  // If landmark detection was enabled (mouth, ears, eyes, cheeks, and
                  // nose available):
                  if let leftEye = face.landmark(ofType: .leftEye) {
                    let leftEyePosition = leftEye.position
                  }

                  // If contour detection was enabled:
                  if let leftEyeContour = face.contour(ofType: .leftEye) {
                    let leftEyePoints = leftEyeContour.points
                  }
                  if let upperLipBottomContour = face.contour(ofType: .upperLipBottom) {
                    let upperLipBottomPoints = upperLipBottomContour.points
                  }

                  // If classification was enabled:
                  if face.hasSmilingProbability {
                    let smileProb = face.smilingProbability
                  }
                  if face.hasRightEyeOpenProbability {
                    let rightEyeOpenProb = face.rightEyeOpenProbability
                  }

                  // If face tracking was enabled:
                  if face.hasTrackingID {
                    let trackingId = face.trackingID
                  }
                }
            }
            
            
           

        }
        dismiss(animated: true, completion: nil)
        

       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
