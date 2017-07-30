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

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
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
  
  @IBAction func sharePoem(_ sender: AnyObject) {
    
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
    activityIndicator.removeFromSuperview()
    activityIndicator = nil
  }
  
  
  // The remaining methods handle the keyboard resignation/
  // move the view so that the first responders aren't hidden
  
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
  
  @IBAction func backgroundTapped(_ sender: AnyObject) {
    view.endEditing(true)
    moveViewDown()
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    moveViewUp()
  }
  
  @IBAction private func textFieldEndEditing(_ sender: AnyObject) {
    view.endEditing(true)
    moveViewDown()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    moveViewDown()
  }
  //MARK: - Tessaract Usage + Documentation
  func performImageRecognition(image: UIImage) {

    let tesseract = G8Tesseract()
    tesseract.language = "eng"
    //  tesseract.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{}[]()+-=?", forKey: "tessedit_char_whitelist")
    tesseract.engineMode = .tesseractCubeCombined
    tesseract.pageSegmentationMode = .auto
    tesseract.maximumRecognitionTime = 300.0
    
    let image = image.toGrayScale()
    let temp = image.fixOrientation()
    let image1 = temp.binarise().scaleImage()
//    img2.image = image1.sliderContrastValueChanged(sender: 0.8)
    self.applyBlurEffect(image: image1)
//    img1.image = image1
    img1.image = image1
    tesseract.image =  image1//image.g8_blackAndWhite()
    tesseract.recognize()
    textView.text = tesseract.recognizedText
    textView.isEditable = true
    removeActivityIndicator()
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
     let image = info[UIImagePickerControllerEditedImage] as! UIImage
    let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
    addActivityIndicator()
    dismiss(animated: true, completion: {
      self.performImageRecognition(image: image)
    })
  }

  func applyBlurEffect(image: UIImage){
    var imageToBlur = CIImage(image: image)
    var blurfilter = CIFilter(name: "CIGaussianBlur")
    blurfilter?.setValue(imageToBlur, forKey: "inputImage")
    blurfilter?.setValue(1, forKey: "inputRadius")
    var resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
    var blurredImage = UIImage(ciImage: resultImage)
    self.img2.image = blurredImage
    
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
    /*contrastFilter.setValue(NSNumber(float: sender.value), forKey: "inputContrast")
     outputImage = contrastFilter.outputImage;
     var cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
     newUIImage = UIImage(CGImage: cgimg)!
     imageView.image = newUIImage;*/
    let glContext = EAGLContext(api: .openGLES2)!
    let ciContext = CIContext(eaglContext: glContext, options: [kCIContextOutputColorSpace : NSNull()])
    let filter = CIFilter(name: "CIPhotoEffectMono")
    filter!.setValue(CIImage(image: self), forKey: "inputImage")
    let outputImage = filter!.outputImage
    let cgimg = ciContext.createCGImage(outputImage!, from: (outputImage?.extent)!)
    
    return UIImage(cgImage: cgimg!)
  }
  
//  func sliderContrastValueChanged(sender: Float) -> UIImage
//  {
//    var context = CIContext()
//    var outputImage = CIImage()
//    var newUIImage = UIImage()
//    var contrastFilter: CIFilter?
//    contrastFilter?.setValue(sender, forKey: "inputContrast")
////    contrastFilter.setValue(NSNumber(value: sender), forKey: "inputContrast")
//    outputImage = (contrastFilter?.outputImage!)!
//    var cgimg = context.createCGImage(outputImage, from: outputImage.extent)
//    newUIImage = UIImage(cgImage: cgimg!)
//    return(newUIImage)
//  }
  
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
//  func fixImageOrientation() -> UIImage? {
//    var flip:Bool = false //used to see if the image is mirrored
//    var isRotatedBy90:Bool = false // used to check whether aspect ratio is to be changed or not
//    
//    var transform = CGAffineTransform.identity
//    
//    //check current orientation of original image
//    switch self.imageOrientation {
//    case .down, .downMirrored:
//      transform = transform.rotated(by: CGFloat(M_PI));
//      
//    case .left, .leftMirrored:
//      transform = transform.rotated(by: CGFloat(M_PI_2));
//      isRotatedBy90 = true
//    case .right, .rightMirrored:
//      transform = transform.rotated(by: CGFloat(-M_PI_2));
//      isRotatedBy90 = true
//    case .up, .upMirrored:
//      break
//    }
//    
//    switch self.imageOrientation {
//      
//    case .upMirrored, .downMirrored:
//      transform = transform.translatedBy(x: self.size.width, y: 0)
//      flip = true
//      
//    case .leftMirrored, .rightMirrored:
//      transform = transform.translatedBy(x: self.size.height, y: 0)
//      flip = true
//    default:
//      break;
//    }
//    
//    // calculate the size of the rotated view's containing box for our drawing space
//    let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint(x:0, y:0), size: size))
//    rotatedViewBox.transform = transform
//    let rotatedSize = rotatedViewBox.frame.size
//    
//    // Create the bitmap context
//    UIGraphicsBeginImageContext(rotatedSize)
//    let bitmap = UIGraphicsGetCurrentContext()
//    
//    // Move the origin to the middle of the image so we will rotate and scale around the center.
//    bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
//    
//    // Now, draw the rotated/scaled image into the context
//    var yFlip: CGFloat
//    
//    if(flip){
//      yFlip = CGFloat(-1.0)
//    } else {
//      yFlip = CGFloat(1.0)
//    }
//    
//    bitmap!.scaleBy(x: yFlip, y: -1.0)
//    
//    //check if we have to fix the aspect ratio
//    if isRotatedBy90 {
//      bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.height,height: size.width))
//    } else {
//      bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width,height: size.height))
//    }
//    
//    let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    return fixedImage
//  }
  
}
