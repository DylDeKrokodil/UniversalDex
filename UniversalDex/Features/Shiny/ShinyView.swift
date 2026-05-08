//
//  ShinyView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct ShinyView: View {
    @StateObject private var viewModel = ShinyHuntViewModel()
    @State private var isPresentingNewHunt = false
    @State private var navigationPath: [ShinyHunt.ID] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.hunts.isEmpty {
                    emptyState
                } else {
                    huntList
                }
            }
            .navigationTitle(AppTab.shiny.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        isPresentingNewHunt = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Start shiny hunt")
                }
            }
            .sheet(isPresented: $isPresentingNewHunt) {
                NewShinyHuntView { hunt in
                    viewModel.add(hunt)
                    navigationPath = [hunt.id]
                }
            }
            .navigationDestination(for: ShinyHunt.ID.self) { huntID in
                ShinyHuntDetailView(viewModel: viewModel, huntID: huntID)
            }
        }
    }

    private var huntList: some View {
        List {
            if !viewModel.activeHunts.isEmpty {
                Section("Hunting") {
                    ForEach(viewModel.activeHunts) { hunt in
                        huntRow(hunt)
                    }
                }
            }

            if !viewModel.caughtHunts.isEmpty {
                Section("Caught") {
                    ForEach(viewModel.caughtHunts) { hunt in
                        huntRow(hunt)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.screenBackground)
    }

    private var emptyState: some View {
        ZStack {
            AppTheme.screenBackground
                .ignoresSafeArea()

            ContentUnavailableView {
                Label("No shiny hunts yet", systemImage: "sparkles")
            } description: {
                Text("Start a hunt, choose the game and method, then tap each encounter until it shines.")
            } actions: {
                Button("Start Hunt") {
                    isPresentingNewHunt = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func huntRow(_ hunt: ShinyHunt) -> some View {
        NavigationLink(value: hunt.id) {
            ShinyHuntCard(hunt: hunt)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.delete(hunt)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ShinyView_Previews: PreviewProvider {
    static var previews: some View {
        ShinyView()
    }
}
