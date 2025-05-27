//
//  SearchBarView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/6/25.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray)
                .padding(.leading, 10)
            TextField(text: $searchText, label: {
                HStack {
                    Text("Menu Item...")
                        .foregroundColor(Color.gray)
                }
            })
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            Image(systemName: "xmark")
                .foregroundColor(Color.gray)
                .frame(alignment: .trailing)
                .padding(.trailing)
                .onTapGesture {
                    searchText = ""
                    xtapped()
                }
                .opacity(searchText == "" ? 0 : 1)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.gray.opacity(0.15))
        )
    }
    
    private func xtapped() {
        UIApplication.shared.endEditing()
    }
}

#Preview {
    SearchBarView(searchText: .constant("Corn Dogs"))
}
