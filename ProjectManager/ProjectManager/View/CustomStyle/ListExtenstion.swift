//
//  ListExtenstion.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/12.
//

import Foundation
import SwiftUI
import Introspect

extension List{
      func removeBackground() -> some View {
        return introspectTableView { tableView in
          tableView.backgroundColor = .clear
          tableView.enclosingScrollView!.drawsBackground = false
        }
      }
}
