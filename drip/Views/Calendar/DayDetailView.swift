//
//  DayDetailView.swift
//  drip
//

import SwiftData
import SwiftUI

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLogs: [OutfitLog]

    let date: Date

    @State private var showOutfitPicker = false

    private let calendar = Calendar.current

    private var plannedLogs: [OutfitLog] {
        allLogs.filter { log in
            log.type == .planned && calendar.isDate(log.date, inSameDayAs: date)
        }
    }

    private var wornLogs: [OutfitLog] {
        allLogs.filter { log in
            log.type == .worn && calendar.isDate(log.date, inSameDayAs: date)
        }
    }

    private var plannedOutfits: [Outfit] {
        plannedLogs.compactMap(\.outfit)
    }

    private var wornOutfits: [Outfit] {
        Array(Set(wornLogs.compactMap(\.outfit)))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(Constants.Strings.plannedSection) {
                    if plannedOutfits.isEmpty {
                        Text("No outfits planned")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(plannedOutfits) { outfit in
                            outfitRow(outfit, showMarkWorn: true)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                let outfit = plannedOutfits[index]
                                if let log = plannedLogs.first(where: { $0.outfit?.id == outfit.id }) {
                                    modelContext.delete(log)
                                }
                            }
                            try? modelContext.save()
                        }
                    }
                }

                Section(Constants.Strings.wornSection) {
                    if wornOutfits.isEmpty {
                        Text("Nothing worn this day")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(wornOutfits) { outfit in
                            outfitRow(outfit, showMarkWorn: false)
                        }
                    }
                }

                Section {
                    Button {
                        showOutfitPicker = true
                    } label: {
                        Label(Constants.Strings.planOutfit, systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOutfitPicker) {
                OutfitPickerSheet(date: date)
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func outfitRow(_ outfit: Outfit, showMarkWorn: Bool) -> some View {
        HStack(spacing: 12) {
            if let imageData = outfit.previewImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: outfit.occasion.systemImage)
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(outfit.name)
                    .font(.subheadline.weight(.medium))
                Text(outfit.occasion.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if showMarkWorn {
                Button {
                    let wornLog = OutfitLog(type: .worn, date: date, outfit: outfit)
                    modelContext.insert(wornLog)
                    try? modelContext.save()
                } label: {
                    Label("Wore it", systemImage: "checkmark.circle")
                        .font(.caption)
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.green)
            }
        }
    }
}

#Preview {
    DayDetailView(date: Date())
        .modelContainer(PreviewData.previewContainer)
}
