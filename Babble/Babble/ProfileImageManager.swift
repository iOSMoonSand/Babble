//
//  ProfileImageManager.swift
//  Babble
//
//  Created by Alexis Schreier on 08/02/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

class ProfileImageManager {

    static let sharedManager = ProfileImageManager()
    static let profileImageName = "profileImageName"
    var localImagePath: String?
    
    //add methods for saving and loading image
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func saveImage(image: UIImage, path: String) -> Bool {
        let pngImageData = UIImagePNGRepresentation(image)
        let result = pngImageData!.writeToFile(path, atomically: true)
        return result
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
}