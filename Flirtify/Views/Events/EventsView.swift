import SwiftUI

private let eventDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct EventsView: View {
    let viewModel: EventsViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.22),
                    Color.cyan.opacity(0.16),
                    Color.orange.opacity(0.14),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    summaryCard
                    categoryFilters

                    if viewModel.events.isEmpty {
                        EmptyStateView(
                            title: "Aucun evenement",
                            subtitle: "Essaie une autre categorie ou retire le filtre de zone.",
                            symbol: "calendar.badge.exclamationmark"
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.events) { event in
                                NavigationLink {
                                    EventDetailView(viewModel: viewModel, eventID: event.id)
                                } label: {
                                    eventCard(event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Evenements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadEvents()
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Autour de toi")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.events.count) evenement\(viewModel.events.count > 1 ? "s" : "") visible\(viewModel.events.count > 1 ? "s" : "")")
                    .font(.title3.weight(.bold))
                Text(viewModel.locationStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button {
                viewModel.nearMeOnly.toggle()
            } label: {
                Text(viewModel.nearMeOnly ? "Proche (\(viewModel.nearbyRadiusKilometers) km)" : "Toutes zones")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.blue.opacity(0.72))
                    )
            }
            .buttonStyle(.plain)
        }
        .overlay(alignment: .bottomLeading) {
            if viewModel.canRequestLocationAuthorization {
                Button {
                    viewModel.requestLocationAccess()
                } label: {
                    Label("Activer la geolocalisation", systemImage: "location.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.88))
                        )
                }
                .buttonStyle(.plain)
                .padding(.leading, 16)
                .padding(.bottom, -14)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "Tous", isActive: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(LocalEventCategory.allCases) { category in
                    categoryChip(
                        title: category.label,
                        icon: category.systemImage,
                        isActive: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    private func categoryChip(
        title: String,
        icon: String? = nil,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isActive ? Color.white : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? Color.blue.opacity(0.74) : Color.white.opacity(0.24))
            )
        }
        .buttonStyle(.plain)
    }

    private func eventCard(_ event: LocalEvent) -> some View {
        let candidateCount = viewModel.matchCandidates(for: event).count

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.category.systemImage)
                .font(.title3.weight(.bold))
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.16))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(event.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer(minLength: 0)

                    Text(event.category.label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text("\(event.city) · \(event.venue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(eventDateFormatter.string(from: event.startsAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let distanceLabel = viewModel.distanceLabel(for: event) {
                        Text("· \(distanceLabel)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                }

                Text(event.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text("\(candidateCount) profil\(candidateCount > 1 ? "s" : "") compatible\(candidateCount > 1 ? "s" : "")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct EventDetailView: View {
    let viewModel: EventsViewModel
    let eventID: UUID

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let event = viewModel.event(with: eventID) {
                VStack(alignment: .leading, spacing: 18) {
                    detailHeader(event)
                    matchingSection(event)
                }
                .padding(20)
            } else {
                EmptyStateView(
                    title: "Evenement indisponible",
                    subtitle: "Reviens dans un instant.",
                    symbol: "calendar.badge.exclamationmark"
                )
                .padding(.top, 40)
            }
        }
        .navigationTitle("Detail evenement")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadEvents()
        }
    }

    private func detailHeader(_ event: LocalEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.title)
                    .font(.title3.weight(.bold))
                Spacer(minLength: 0)
                Text(event.category.label)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text("\(event.city) · \(event.venue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(eventDateFormatter.string(from: event.startsAt))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let distanceLabel = viewModel.distanceLabel(for: event) {
                Text("Distance: \(distanceLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            Text(event.summary)
                .font(.body)

            Text("\(event.attendeeUserIDs.count) participant\(event.attendeeUserIDs.count > 1 ? "s" : "")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                viewModel.toggleParticipation(for: event.id)
            } label: {
                Text(viewModel.isParticipating(in: event) ? "Quitter l'evenement" : "Participer a l'evenement")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(viewModel.isParticipating(in: event) ? Color.red.opacity(0.8) : Color.blue.opacity(0.82))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func matchingSection(_ event: LocalEvent) -> some View {
        let candidates = viewModel.matchCandidates(for: event)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Matching autour de cet event")
                .font(.headline)

            if candidates.isEmpty {
                EmptyStateView(
                    title: "Pas de profils compatibles",
                    subtitle: "Essaie un autre event ou agrandis tes filtres dans Decouvrir.",
                    symbol: "person.2.slash"
                )
                .padding(.top, 8)
            } else {
                ForEach(candidates) { profile in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            ProfilePhotoView(
                                photoData: profile.primaryPhotoData,
                                fallbackSymbol: profile.photoSymbol,
                                size: 54,
                                backgroundColor: Color.blue.opacity(0.13),
                                symbolColor: .blue,
                                strokeColor: Color.blue.opacity(0.25)
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(profile.headline)
                                    .font(.headline.weight(.semibold))
                                Text(profile.city)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 0)
                        }

                        Text(profile.bio)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        let sharedInterests = viewModel.sharedInterests(with: profile)
                        if !sharedInterests.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(sharedInterests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.16))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
    }
}
