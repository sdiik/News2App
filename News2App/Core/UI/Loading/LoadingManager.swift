//
//  LoadingManager.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import Combine
import SwiftUI

class LoadingManager: ObservableObject {
    @Published var isLoading: Bool = false
}
