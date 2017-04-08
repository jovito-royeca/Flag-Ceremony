//
//  CommonViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 06/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit
import MMDrawerController

class CommonViewController: UIViewController {

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Custom methods
    func showMenu() {
        if let navigationVC = mm_drawerController.leftDrawerViewController as? UINavigationController {
            var menuView:MenuViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is MenuViewController {
                    menuView = drawer as? MenuViewController
                }
            }
            if menuView == nil {
                menuView = MenuViewController()
                navigationVC.addChildViewController(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }

    func showCountryList() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.performSegue(withIdentifier: "showCountriesAsPush", sender: nil)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            self.performSegue(withIdentifier: "showCountriesAsPopup", sender: nil)
        }
    }
}