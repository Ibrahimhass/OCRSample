//
//  ViewController.swift
//  LoveInASnap
//
//  Created by Lyndsey Scott on 1/11/15
//  for http://www.raywenderlich.com/
//  Copyright (c) 2015 Lyndsey Scott. All rights reserved.
//

import UIKit
import Foundation
import CoreImage
import GPUImage
import CoreImage

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var findTextField: UITextField!
  @IBOutlet weak var replaceTextField: UITextField!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var img1: UIImageView!
  
  @IBOutlet weak var img2: UIImageView!
  var activityIndicator:UIActivityIndicatorView!
  var originalTopMargin:CGFloat!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    originalTopMargin = topMarginConstraint.constant
  }
  
  @IBAction func takePhoto(_ sender: AnyObject) {
    view.endEditing(true)
    moveViewDown()
    let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                   message: nil, preferredStyle: .actionSheet)
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraButton = UIAlertAction(title: "Take Photo",
                                       style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .camera
                                        imagePicker.allowsEditing = true
                                        self.present(imagePicker, animated: true, completion: nil)
      }
      imagePickerActionSheet.addAction(cameraButton)
    }
    let libraryButton = UIAlertAction(title: "Choose Existing",
                                      style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .photoLibrary
                                        imagePicker.allowsEditing = true
                                        self.present(imagePicker, animated: true, completion: nil)
    }
    imagePickerActionSheet.addAction(libraryButton)
    let cancelButton = UIAlertAction(title: "Cancel",
                                     style: .cancel) { (alert) -> Void in
    }
    imagePickerActionSheet.addAction(cancelButton)
    present(imagePickerActionSheet, animated: true,
            completion: nil)
  }
  
  func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
    
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    var scaleFactor: CGFloat
    
    if image.size.width > image.size.height {
      scaleFactor = image.size.height / image.size.width
      scaledSize.width = maxDimension
      scaledSize.height = scaledSize.width * scaleFactor
    } else {
      scaleFactor = image.size.width / image.size.height
      scaledSize.height = maxDimension
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    image.draw(in: CGRect.init(x: 0, y: 0, width:  scaledSize.width, height: scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
  }
  
  @IBAction func swapText(_ sender: AnyObject) {
    if let _ = textView.text, let findText = findTextField.text,
      let replaceText = replaceTextField.text {
      textView.text =
        textView.text.replacingOccurrences(of: findText, with: replaceText, options: [], range: nil)
      findTextField.text = nil
      replaceTextField.text = nil
      view.endEditing(true)
      moveViewDown()
    }
  }
  
  
  // Activity Indicator methods
  
  func addActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: view.bounds)
    activityIndicator.activityIndicatorViewStyle = .whiteLarge
    activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
  }
  
  func removeActivityIndicator() {
    if (activityIndicator != nil){
      activityIndicator.removeFromSuperview()
      activityIndicator = nil
    }
  }
  
  
  
  func moveViewUp() {
    if topMarginConstraint.constant != originalTopMargin {
      return
    }
    
    topMarginConstraint.constant -= 135
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func moveViewDown() {
    if topMarginConstraint.constant == originalTopMargin {
      return
    }
    
    topMarginConstraint.constant = originalTopMargin
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    
  }


  //MARK: - Tessaract Usage + Documentation
  func performImageRecognition(image: UIImage) {
    
    let tesseract = G8Tesseract()
    tesseract.language = "eng"
    //  tesseract.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{}[]()+-=?", forKey: "tessedit_char_whitelist")
    tesseract.engineMode = .tesseractCubeCombined
    tesseract.pageSegmentationMode = .auto
    tesseract.maximumRecognitionTime = 300.0
    
    
    let image0 = image.toGrayScale()
    let temp = image0.fixOrientation()
    let image1 = temp.binarise().scaleImage()

//    let img0 = AdaptiveThreshold.init()
//    img0.blurRadiusInPixels = 4.0
//    let filteredImage3 = filteredImage2.filterWithOperation(img0)
    
    
////    let finalImage = self.detect(inputImage: filteredImage2)
//    
//    var imageToBlur = CIImage(image: filteredImage2)
//    var blurfilter = CIFilter(name: "CIGaussianBlur")
//    blurfilter?.setValue(imageToBlur, forKey: "inputImage")
//    blurfilter?.setValue(4, forKey: "inputRadius")
//    var resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
//    var blurredImage = UIImage(ciImage: resultImage)
    
    img1.image = image1
//    img2.image = image1
    tesseract.image =  image1//image.g8_blackAndWhite()
    tesseract.recognize()
    textView.text = tesseract.recognizedText
    textView.isEditable = true
    removeActivityIndicator()

    if (tesseract.recognizedText.characters.count == 0){
      self.performWithAdaptiveFilter(image: image)
//      removeActivityIndicator()
//      addActivityIndicator()
    }
  }
  
  func performWithAdaptiveFilter(image : UIImage){
    
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 300.0
    
        let img = AdaptiveThreshold.init()
        img.blurRadiusInPixels = 1.0
        let filteredImage2 = image.filterWithOperation(img)
        img2.image = filteredImage2
    
        tesseract.image =  filteredImage2//image.g8_blackAndWhite()
        tesseract.recognize()
        textView.text = tesseract.recognizedText
        textView.isEditable = true
//        removeActivityIndicator()

  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
     let image = info[UIImagePickerControllerEditedImage] as! UIImage
    let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
    addActivityIndicator()
    dismiss(animated: true, completion: {
      self.performImageRecognition(image: image)
    })
  }
}
extension UIImage {
  
  func toGrayScale() -> UIImage {
    
    let greyImage = UIImageView()
    greyImage.image = self
    let context = CIContext.yourprefix_context(options: nil)//CIContext(options: nil)
    let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
    currentFilter!.setValue(CIImage(image: greyImage.image!), forKey: kCIInputImageKey)
    let output = currentFilter!.outputImage
    let cgimg = context?.createCGImage(output!,from: output!.extent)
    let processedImage = UIImage(cgImage: cgimg!)
    greyImage.image = processedImage
    
    return greyImage.image!
  }
  
  func binarise() -> UIImage {
    let glContext = EAGLContext(api: .openGLES2)!
    let ciContext = CIContext(eaglContext: glContext, options: [kCIContextOutputColorSpace : NSNull()])
    let filter = CIFilter(name: "CIPhotoEffectMono")
    filter!.setValue(CIImage(image: self), forKey: "inputImage")
    let outputImage = filter!.outputImage
    let cgimg = ciContext.createCGImage(outputImage!, from: (outputImage?.extent)!)
    
    return UIImage(cgImage: cgimg!)
  }
  
  func scaleImage() -> UIImage {
    
    let maxDimension: CGFloat = 640
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    var scaleFactor: CGFloat
    
    if self.size.width > self.size.height {
      scaleFactor = self.size.height / self.size.width
      scaledSize.width = maxDimension
      scaledSize.height = scaledSize.width * scaleFactor
    } else {
      scaleFactor = self.size.width / self.size.height
      scaledSize.height = maxDimension
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    self.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
  }
  
  func fixOrientation() -> UIImage {
    
    // No-op if the orientation is already correct
    if ( self.imageOrientation == UIImageOrientation.up ) {
      return self;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    if ( self.imageOrientation == UIImageOrientation.down || self.imageOrientation == UIImageOrientation.downMirrored ) {
      transform = transform.translatedBy(x: self.size.width, y: self.size.height)
      transform = transform.rotated(by: CGFloat(Double.pi))
    }
    
    if ( self.imageOrientation == UIImageOrientation.left || self.imageOrientation == UIImageOrientation.leftMirrored ) {
      transform = transform.translatedBy(x: self.size.width, y: 0)
      transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
    }
    
    if ( self.imageOrientation == UIImageOrientation.right || self.imageOrientation == UIImageOrientation.rightMirrored ) {
      transform = transform.translatedBy(x: 0, y: self.size.height);
      transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
    }
    
    if ( self.imageOrientation == UIImageOrientation.upMirrored || self.imageOrientation == UIImageOrientation.downMirrored ) {
      transform = transform.translatedBy(x: self.size.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    }
    
    if ( self.imageOrientation == UIImageOrientation.leftMirrored || self.imageOrientation == UIImageOrientation.rightMirrored ) {
      transform = transform.translatedBy(x: self.size.height, y: 0);
      transform = transform.scaledBy(x: -1, y: 1);
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                   bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                   space: self.cgImage!.colorSpace!,
                                   bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
    
    ctx.concatenate(transform)
    
    if ( self.imageOrientation == UIImageOrientation.left ||
      self.imageOrientation == UIImageOrientation.leftMirrored ||
      self.imageOrientation == UIImageOrientation.right ||
      self.imageOrientation == UIImageOrientation.rightMirrored ) {
      ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
    } else {
      ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
    }
    
    // And now we just create a new UIImage from the drawing context and return it
    return UIImage(cgImage: ctx.makeImage()!)
  }
}
/*func detect(inputImage : UIImage) -> UIImage? {
 guard let personciImage = CIImage(image: inputImage) else {
 return nil
 }
 
 let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
 if #available(iOS 9.0, *) {
 let faceDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: accuracy)
 
 let faces = faceDetector?.features(in: personciImage)
 
 for face in faces as! [CITextFeature] {
 
 print("Found bounds are \(face.bounds)")
 
 //        let faceBox = UIView(frame: face.bounds)
 //
 //        faceBox.layer.borderWidth = 3
 //        faceBox.layer.borderColor = UIColor.red.cgColor
 //        faceBox.backgroundColor = UIColor.clear
 
 return nil
 //        personPic.addSubview(faceBox)
 
 
 }
 
 } else {
 // Fallback on earlier versions
 }
 
 return nil
 }
*/
