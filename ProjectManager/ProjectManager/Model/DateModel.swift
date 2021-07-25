//
//  DateModel.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/25.
//

import Foundation
import SwiftUI

extension Date{
    func get(_ components : Calendar.Component...,calender : Calendar = Calendar.current)->DateComponents{
        return calender.dateComponents(Set(components), from: self)
    }
    func get(_ component : Calendar.Component ,calender : Calendar = Calendar.current)->Int{
        return calender.component(component, from: self)
    }
}
