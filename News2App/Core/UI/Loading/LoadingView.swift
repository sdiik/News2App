//
//  LoadingView.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var loadingManager: LoadingManager

    var body: some View {
        if loadingManager.isLoading {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding(20)
                    .background(Color.clear)
                    .cornerRadius(10)
            }
        }
    }
}
