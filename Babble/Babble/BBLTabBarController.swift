//
//  BBLTabBarController.swift
//  Babble
//
//  Created by Alexis Schreier on 01/16/17.
//  Copyright © 2017 Alexis Schreier. All rights reserved.
//

import UIKit

class BBLTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = UIColor(red:0.11, green:0.57, blue:0.63, alpha:1.0)
        
        let tabBarAppearence = UITabBarItem.appearance()
        self.tabBar.tintColor = .white
        let unselectedItem = [NSForegroundColorAttributeName: UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)]
        let selectedItem = [NSForegroundColorAttributeName: UIColor.white]
        tabBarAppearence.setTitleTextAttributes(unselectedItem, for: .normal)
        tabBarAppearence.setTitleTextAttributes(selectedItem, for: .selected)
        let homeItem = self.tabBar.items?[0]
        homeItem?.image = UIImage(named: "unselected_roofing")?.withRenderingMode(.alwaysOriginal)
        homeItem?.selectedImage = UIImage(named: "selected_roofing")
        let profileItem = self.tabBar.items?[1]
        profileItem?.image = UIImage(named: "unselected_user")?.withRenderingMode(.alwaysOriginal)
        profileItem?.selectedImage = UIImage(named: "selected_user")
    }
}
