//
//  UtilsView.swift
//  DoTogether
//
//  Created by Long Sen on 7/24/22.
//

import SwiftUI
import SDWebImageSwiftUI

extension View {
    @ViewBuilder
    func ImageView(url: String, in size: CGFloat) -> some View {
        WebImage(url: URL(string: url))
            .resizable()
            .placeholder {
                ZStack {
                    Circle().foregroundColor(.gray.opacity(0.5))
                    Image(systemName: "person.fill")
                }
            }
            .indicator { isAnimating,progress in
                ProgressView()
            }
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
