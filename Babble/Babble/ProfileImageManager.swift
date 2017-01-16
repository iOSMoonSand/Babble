//
//  ProfileImageManager.swift
//  Babble
//
//  Created by Alexis Schreier on 08/02/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

class ProfileImageManager {

    static let sharedInsance = ProfileImageManager()
    static let profileImageName = "profileImageName"
    var localImagePath: String?
    
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }
    
    func saveImage(_ image: UIImage, path: String) -> Bool {
        let pngImageData = UIImagePNGRepresentation(image)
        let result = (try? pngImageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        return result
    }
    
    func loadImageFromPath(_ path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
}
