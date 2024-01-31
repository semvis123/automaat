//
//  widget.swift
//  widget
//
//  Created by Sem Visscher on 30/01/2024.
//

import WidgetKit
import SwiftUI

struct AutomaatWidget: Widget {
    let kind = "Automagic"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) {
            EntryView(entry: $0)
        }
        .configurationDisplayName("Automagic Widget")
        .description("Huidige reservering.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
