//
//  CarFilterView.swift
//  automaat
//
//  Created by Sem Visscher on 25/01/2024.
//

import SwiftUI

struct CarSortOption: Hashable {
    var label: String
    var comparable: (Car) -> Int64
    
    static func == (lhs: CarSortOption, rhs: CarSortOption) -> Bool {
        lhs.label == rhs.label
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}

struct CarFilter {
    var onlyFavorite: Bool
    var sortKey: CarSortOption
}


struct CarFilterView: View {
    @Binding var filter: CarFilter
    var sortOptions: [CarSortOption] = [
        CarSortOption(label: "ID", comparable: { $0.backendId }),
        CarSortOption(label: "Prijs", comparable: { $0.price }),
    ]
    var body: some View {
        List {
            Toggle("Favorieten", isOn: $filter.onlyFavorite)
            HStack {
                Picker("Sorteer veld", selection: $filter.sortKey) {
                    ForEach(sortOptions, id: \.label) {
                        Text($0.label).tag($0)
                    }
                }
            }
        }
    }
}
