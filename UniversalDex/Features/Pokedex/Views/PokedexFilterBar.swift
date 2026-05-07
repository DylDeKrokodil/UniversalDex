//
//  PokedexFilterBar.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokedexFilterBar: View {
    @Binding var selectedGeneration: PokedexGeneration
    @Binding var sortOption: PokedexSortOption

    var body: some View {
        HStack(spacing: 10) {
            Menu {
                Picker("Generation", selection: $selectedGeneration) {
                    ForEach(PokedexGeneration.allCases) { generation in
                        Text(generation.title)
                            .tag(generation)
                    }
                }
            } label: {
                Label(selectedGeneration.title, systemImage: "line.3.horizontal.decrease.circle")
            }

            Menu {
                Picker("Sort", selection: $sortOption) {
                    ForEach(PokedexSortOption.allCases) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
            } label: {
                Label(sortOption.title, systemImage: "arrow.up.arrow.down")
            }

            Spacer()
        }
        .font(.subheadline.weight(.semibold))
        .buttonStyle(.bordered)
        .padding(.horizontal, 12)
        .padding(.top, 10)
    }
}

struct PokedexFilterBar_Previews: PreviewProvider {
    static var previews: some View {
        PokedexFilterBar(
            selectedGeneration: .constant(.all),
            sortOption: .constant(.numberAscending)
        )
        .padding()
    }
}
