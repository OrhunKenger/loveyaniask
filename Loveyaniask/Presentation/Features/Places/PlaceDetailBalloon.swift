//
//  PlaceDetailBalloon.swift
//  Loveyaniask
//
//  Pine basınca açılan balon kart: detay + ikili puan (kendi puanını ver).
//

import SwiftUI

struct PlaceDetailBalloon: View {
    let viewModel: PlacesViewModel
    let placeId: UUID
    var onClose: () -> Void

    private var place: Place? { viewModel.place(by: placeId) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let place {
                HStack {
                    Text(place.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                if let data = viewModel.photoData(for: place), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                HStack(spacing: AppSpacing.xs) {
                    starsRow(for: Int(place.averageRating.rounded()))
                    Text(viewModel.averageText(for: place))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                    Text("(ortalama)")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Divider()

                // Senin puanın (etkileşimli)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Senin puanın")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    interactiveStars(for: place)
                }

                // Partnerin puanı
                let partner = viewModel.currentUser.partner
                HStack {
                    Text(partner.firstName)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    let partnerRating = viewModel.rating(of: partner, for: place)
                    if partnerRating > 0 {
                        starsRow(for: partnerRating)
                    } else {
                        Text("puan vermedi")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Text(viewModel.dateText(for: place))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)

                if !place.note.isEmpty {
                    Text(place.note)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Button(role: .destructive) {
                    viewModel.delete(place)
                    onClose()
                } label: {
                    Label("Mekanı sil", systemImage: "trash")
                        .font(.caption)
                }
                .padding(.top, 2)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: 320)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
    }

    private func starsRow(for rating: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(star <= rating ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
            }
        }
    }

    private func interactiveStars(for place: Place) -> some View {
        let mine = viewModel.myRating(for: place)
        return HStack(spacing: AppSpacing.xs) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= mine ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(star <= mine ? AppColors.primary : AppColors.textSecondary)
                    .onTapGesture {
                        viewModel.setMyRating(place, rating: star)
                    }
            }
        }
    }
}
