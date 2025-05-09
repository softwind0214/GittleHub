//
//  Appearance.Tab.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI

extension UITabBar {
    static func setupAppearance() {
        let appearance = UITabBarAppearance()
        // 设置半透明背景颜色，这里使用了 0.5 的透明度
        appearance.backgroundColor = .init(named: "tab.bg")
        appearance.backgroundEffect = .none
        // 设置背景图片为透明，确保自定义颜色生效
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        
        appearance.stackedLayoutAppearance.selected.iconColor = .accent
        appearance.stackedLayoutAppearance.normal.iconColor = .init(named: "tab.normal")
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.accent
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "tab.normal") as Any
        ]

        // 将外观应用到不同的配置中
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
