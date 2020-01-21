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
    
    private lazy var annotationOverlayView: UIView = {
       precondition(isViewLoaded)
       let annotationOverlayView = UIView(frame: .zero)
       annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
       return annotationOverlayView
     }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.options.contourMode = .all
        self.options.landmarkMode = .all
        self.options.classificationMode = .all
        self.options.performanceMode = .accurate
        self.options.minFaceSize = CGFloat(0.1)
        
        imageView.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
          annotationOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
          annotationOverlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
          annotationOverlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
          annotationOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
          ])
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
                self.processResult(from: faces, error: error)
                /*
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
                    print("LEFT EYE", leftEyePosition)
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
                }*/
            }
            
            
           

        }
        dismiss(animated: true, completion: nil)
        

       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Removes the detection annotations from the annotation overlay view.
    private func removeDetectionAnnotations() {
      for annotationView in annotationOverlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }
    
    func processResult(from faces: [VisionFace]?, error: Error?) {
       removeDetectionAnnotations()
       guard let faces = faces else {
         return
       }

       for feature in faces {
         let transform = self.transformMatrix()
         let transformedRect = feature.frame.applying(transform)
         UIUtilities.addRectangle(
           transformedRect,
           to: self.annotationOverlayView,
           color: UIColor.green
         )
         self.addContours(forFace: feature, transform: transform)
       }
     }

     private func addContours(forFace face: VisionFace, transform: CGAffineTransform) {
       // Face
       if let faceContour = face.contour(ofType: .face) {
         for point in faceContour.points {
           drawPoint(point, in: .blue, transform: transform)
         }
       }

       // Eyebrows
       if let topLeftEyebrowContour = face.contour(ofType: .leftEyebrowTop) {
         for point in topLeftEyebrowContour.points {
           drawPoint(point, in: .orange, transform: transform)
         }
       }
       if let bottomLeftEyebrowContour = face.contour(ofType: .leftEyebrowBottom) {
         for point in bottomLeftEyebrowContour.points {
           drawPoint(point, in: .orange, transform: transform)
         }
       }
       if let topRightEyebrowContour = face.contour(ofType: .rightEyebrowTop) {
         for point in topRightEyebrowContour.points {
           drawPoint(point, in: .orange, transform: transform)
         }
       }
       if let bottomRightEyebrowContour = face.contour(ofType: .rightEyebrowBottom) {
         for point in bottomRightEyebrowContour.points {
           drawPoint(point, in: .orange, transform: transform)
         }
       }

       // Eyes
       if let leftEyeContour = face.contour(ofType: .leftEye) {
         for point in leftEyeContour.points {
           drawPoint(point, in: .cyan, transform: transform)
         }
       }
       if let rightEyeContour = face.contour(ofType: .rightEye) {
         for point in rightEyeContour.points {
           drawPoint(point, in: .cyan, transform: transform)
         }
       }

       // Lips
       if let topUpperLipContour = face.contour(ofType: .upperLipTop) {
         for point in topUpperLipContour.points {
           drawPoint(point, in: .red, transform: transform)
         }
       }
       if let bottomUpperLipContour = face.contour(ofType: .upperLipBottom) {
         for point in bottomUpperLipContour.points {
           drawPoint(point, in: .red, transform: transform)
         }
       }
       if let topLowerLipContour = face.contour(ofType: .lowerLipTop) {
         for point in topLowerLipContour.points {
           drawPoint(point, in: .red, transform: transform)
         }
       }
       if let bottomLowerLipContour = face.contour(ofType: .lowerLipBottom) {
         for point in bottomLowerLipContour.points {
           drawPoint(point, in: .red, transform: transform)
         }
       }

       // Nose
       if let noseBridgeContour = face.contour(ofType: .noseBridge) {
         for point in noseBridgeContour.points {
           drawPoint(point, in: .yellow, transform: transform)
         }
       }
       if let noseBottomContour = face.contour(ofType: .noseBottom) {
         for point in noseBottomContour.points {
           drawPoint(point, in: .yellow, transform: transform)
         }
       }
     }
    
    private func drawPoint(_ point: VisionPoint, in color: UIColor, transform: CGAffineTransform) {
      let transformedPoint = pointFrom(point).applying(transform);
      UIUtilities.addCircle(atPoint: transformedPoint,
                            to: annotationOverlayView,
                            color: color,
                            radius: 5.0)
    }

    private func pointFrom(_ visionPoint: VisionPoint) -> CGPoint {
      return CGPoint(x: CGFloat(visionPoint.x.floatValue), y: CGFloat(visionPoint.y.floatValue))
    }
    
    private func transformMatrix() -> CGAffineTransform {
      guard let image = imageView.image else { return CGAffineTransform() }
      let imageViewWidth = imageView.frame.size.width
      let imageViewHeight = imageView.frame.size.height
      let imageWidth = image.size.width
      let imageHeight = image.size.height

      let imageViewAspectRatio = imageViewWidth / imageViewHeight
      let imageAspectRatio = imageWidth / imageHeight
      let scale = (imageViewAspectRatio > imageAspectRatio) ?
        imageViewHeight / imageHeight :
        imageViewWidth / imageWidth

      // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
      // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
      let scaledImageWidth = imageWidth * scale
      let scaledImageHeight = imageHeight * scale
      let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
      let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)

      var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
      transform = transform.scaledBy(x: scale, y: scale)
      return transform
    }

}
