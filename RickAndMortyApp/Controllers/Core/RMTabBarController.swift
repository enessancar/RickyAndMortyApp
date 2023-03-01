//
//  RMTabBarController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 1.03.2023.
//

import UIKit

class RMTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTabs()
    }

    private func setUpTabs() {
        let characterVC = RMCharacterVC()
        let locationVC = RMLocationVC()
        let episodesVC = RMEpisodeVC()
        let settingsVC = RMSettingsVC()
        
        for vc in [characterVC, locationVC, episodesVC, settingsVC] {
            vc.navigationItem.largeTitleDisplayMode = .automatic
            vc.view.backgroundColor = .systemBackground
        }
        
        let nav1 = UINavigationController(rootViewController: characterVC)
        let nav2 = UINavigationController(rootViewController: locationVC)
        let nav3 = UINavigationController(rootViewController: episodesVC)
        let nav4 = UINavigationController(rootViewController: settingsVC)
        
        nav1.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Locations", image: UIImage(systemName: "globe"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Episodes", image: UIImage(systemName: "tv"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)
        
        for nav in [nav1, nav2, nav3, nav4] {
            nav.navigationBar.prefersLargeTitles = true
        }
        setViewControllers([nav1, nav2, nav3, nav4],animated: true)
    }
}
