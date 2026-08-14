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
                    Image(systemName: "star.fill")
                        .font(.subheadline)
                        .foregroundStyle(viewModel.pinColor(for: place))
                    Text(viewModel.averageText(for: place))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("(ortalama)")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Divider()

                // Senin puanın (etkileşimli)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Senin puanın")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    RatingChipsPicker(current: viewModel.myRating(for: place)) { value in
                        viewModel.setMyRating(place, rating: value)
                    }
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
                        Text("\(partnerRating)/10")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
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
        .glassCard(cornerRadius: 22, padding: 0)
        .shadow(color: .black.opacity(0.45), radius: 24, y: 12)
    }

}
