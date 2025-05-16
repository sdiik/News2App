//
//  BasicView.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import SwiftUI

struct BasicView<Content: View>: View {
    @EnvironmentObject var loadingManager: LoadingManager

    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if loadingManager.isLoading {
                LoadingView()
            }
        }
    }
}
