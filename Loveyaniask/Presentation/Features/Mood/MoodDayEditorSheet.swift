//
//  MoodDayEditorSheet.swift
//  Loveyaniask
//
//  Bir gün için ruh hali + fotoğraf. Sadece KENDİ kartın düzenlenebilir,
//  partnerinki salt-okunur (görüntülenir).
//

import SwiftUI
import PhotosUI

struct MoodDayEditorSheet: View {
    let viewModel: MoodViewModel
    let date: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    ForEach(Partner.allCases) { partner in
                        PartnerMoodCard(
                            viewModel: viewModel,
                            date: date,
                            partner: partner,
                            editable: partner == .me
                        )
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle(viewModel.dayTitle(for: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitti") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct PartnerMoodCard: View {
    let viewModel: MoodViewModel
    let date: Date
    let partner: Partner
    let editable: Bool

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(viewModel.title(for: partner))
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            if editable {
                moodMenu
                photoArea
            } else {
                readOnlyMood
                readOnlyPhoto
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    // MARK: - Düzenlenebilir (kendi kartın)

    private var moodMenu: some View {
        Menu {
            ForEach(Mood.allCases) { mood in
                Button {
                    viewModel.setMood(date: date, partner: partner, mood: mood)
                } label: {
                    Text("\(mood.emoji)  \(mood.label)")
                }
            }
        } label: {
            HStack {
                if let mood = viewModel.mood(for: date, partner: partner) {
                    Text(mood.emoji)
                    Text(mood.label)
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    Text("Ruh hali seç")
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var photoArea: some View {
        VStack(spacing: AppSpacing.sm) {
            if let data = viewModel.photoData(for: date, partner: partner),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(
                    viewModel.photoData(for: date, partner: partner) == nil ? "Fotoğraf ekle" : "Fotoğrafı değiştir",
                    systemImage: "photo"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        viewModel.setPhoto(date: date, partner: partner, imageData: data)
                    }
                }
            }
        }
    }

    // MARK: - Salt-okunur (partnerin kartı)

    private var readOnlyMood: some View {
        HStack {
            if let mood = viewModel.mood(for: date, partner: partner) {
                Text(mood.emoji)
                Text(mood.label)
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                Text("Henüz bir şey paylaşmadı")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var readOnlyPhoto: some View {
        if let data = viewModel.photoData(for: date, partner: partner),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
