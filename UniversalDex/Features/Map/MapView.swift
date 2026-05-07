//
//  MapView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 07/05/2026.
//

import SwiftUI

struct MapView: View {
    @State private var selectedArea: PokemonMapArea?
    @State private var selectedRegion = PokemonMapRegion.kanto
    @State private var selectedGame = PokemonMapRegion.kanto.games[0]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    controls
                    mapOverview
                    areaList
                }
                .padding(16)
            }
            .background(AppTheme.screenBackground)
            .navigationTitle(AppTab.map.title)
            .onChange(of: selectedRegion) { _, region in
                selectedGame = region.games[0]
                selectedArea = nil
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            pickerRow(
                title: "Region",
                value: selectedRegion.displayName,
                systemImage: "globe.europe.africa.fill"
            ) {
                ForEach(PokemonMapRegion.allCases) { region in
                    Button {
                        selectedRegion = region
                    } label: {
                        if selectedRegion == region {
                            Label(region.displayName, systemImage: "checkmark")
                        } else {
                            Text(region.displayName)
                        }
                    }
                }
            }

            pickerRow(
                title: "Game",
                value: selectedGame.displayName,
                systemImage: "gamecontroller.fill"
            ) {
                ForEach(selectedRegion.games) { game in
                    Button {
                        selectedGame = game
                    } label: {
                        if selectedGame == game {
                            Label(game.displayName, systemImage: "checkmark")
                        } else {
                            Text(game.displayName)
                        }
                    }
                }
            }
        }
    }

    private var mapOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: selectedRegion.symbolName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(AppTheme.accentColor)
                    .frame(width: 54, height: 54)
                    .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedRegion.displayName)
                        .font(.title2.bold())

                    Text(selectedGame.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(selectedRegion.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            connectedRouteMap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private var connectedRouteMap: some View {
        let nodes = selectedRegion.mapNodes
        let selectedMapArea = selectedArea ?? nodes.first?.area

        return VStack(alignment: .leading, spacing: 12) {
            GeometryReader { proxy in
                ZStack {
                    ForEach(mapConnections(for: nodes)) { connection in
                        if let startNode = nodes.first(where: { $0.area.id == connection.startID }),
                           let endNode = nodes.first(where: { $0.area.id == connection.endID }) {
                            Path { path in
                                path.move(to: mapPoint(startNode.position, in: proxy.size))
                                path.addLine(to: mapPoint(endNode.position, in: proxy.size))
                            }
                            .stroke(AppTheme.accentColor.opacity(0.32), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                    }

                    ForEach(nodes) { node in
                        Button {
                            selectedArea = node.area
                        } label: {
                            mapNodeLabel(
                                area: node.area,
                                isSelected: selectedMapArea?.id == node.area.id
                            )
                        }
                        .buttonStyle(.plain)
                        .position(mapPoint(node.position, in: proxy.size))
                    }
                }
            }
            .frame(height: selectedRegion.mapHeight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))

            if let selectedMapArea {
                selectedAreaSummary(selectedMapArea)
            }
        }
    }

    private func mapNodeLabel(area: PokemonMapArea, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.accentColor : AppTheme.cardBackground)
                    .shadow(color: .black.opacity(isSelected ? 0.18 : 0.06), radius: 6, y: 3)

                Image(systemName: area.kind.systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? Color.white : AppTheme.accentColor)
            }
            .frame(width: 34, height: 34)

            Text(area.shortName)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .foregroundStyle(isSelected ? AppTheme.accentColor : Color.secondary)
                .frame(width: 54)
        }
        .contentShape(Rectangle())
    }

    private func selectedAreaSummary(_ area: PokemonMapArea) -> some View {
        HStack(spacing: 12) {
            Image(systemName: area.kind.systemImage)
                .font(.headline)
                .foregroundStyle(AppTheme.accentColor)
                .frame(width: 38, height: 38)
                .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(area.name)
                    .font(.headline)

                Text(area.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                let connectedNames = connectedAreaNames(for: area)
                if !connectedNames.isEmpty {
                    Text("Connected to \(connectedNames.joined(separator: ", "))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private var areaList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Places")
                .font(.headline)

            ForEach(selectedRegion.areas) { area in
                Button {
                    selectedArea = area
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: area.kind.systemImage)
                            .font(.headline)
                            .foregroundStyle(AppTheme.accentColor)
                            .frame(width: 34, height: 34)
                            .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(area.name)
                                .font(.subheadline.weight(.semibold))

                            Text(area.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        if selectedArea?.id == area.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private func pickerRow<MenuContent: View>(
        title: String,
        value: String,
        systemImage: String,
        @ViewBuilder menuContent: () -> MenuContent
    ) -> some View {
        Menu {
            menuContent()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(AppTheme.accentColor)

                Text(title)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(value)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.trailing)

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .padding(14)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func mapPoint(_ normalizedPoint: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: normalizedPoint.x * size.width,
            y: normalizedPoint.y * size.height
        )
    }

    private func mapConnections(for nodes: [PokemonMapNode]) -> [PokemonMapConnection] {
        var seenConnectionIDs = Set<String>()
        var connections: [PokemonMapConnection] = []

        for node in nodes {
            for connectedAreaID in node.connectedAreaIDs {
                let sortedIDs = [node.area.id, connectedAreaID].sorted()
                let connectionID = sortedIDs.joined(separator: "->")

                guard !seenConnectionIDs.contains(connectionID) else {
                    continue
                }

                seenConnectionIDs.insert(connectionID)
                connections.append(PokemonMapConnection(
                    id: connectionID,
                    startID: node.area.id,
                    endID: connectedAreaID
                ))
            }
        }

        return connections
    }

    private func connectedAreaNames(for area: PokemonMapArea) -> [String] {
        selectedRegion.mapNodes
            .first { $0.area.id == area.id }?
            .connectedAreaIDs
            .compactMap { connectedAreaID in
                selectedRegion.mapNodes.first { $0.area.id == connectedAreaID }?.area.shortName
            } ?? []
    }
}

private enum PokemonMapRegion: String, CaseIterable, Identifiable {
    case kanto
    case johto
    case hoenn
    case sinnoh
    case unova
    case kalos
    case alola
    case galar
    case paldea

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .kanto, .johto:
            return "leaf.fill"
        case .hoenn, .alola:
            return "water.waves"
        case .sinnoh, .galar:
            return "mountain.2.fill"
        case .unova, .kalos:
            return "building.2.fill"
        case .paldea:
            return "sun.max.fill"
        }
    }

    var summary: String {
        switch self {
        case .kanto:
            return "Classic towns, Routes 1-25, caves, forests, and sea routes."
        case .johto:
            return "Western towns, Routes 29-48, towers, forests, and the road back to Kanto."
        case .hoenn:
            return "Land and sea routes, volcanic paths, deep water, and island towns."
        case .sinnoh:
            return "Mountain routes around Mt. Coronet, lakes, caves, and snowy northern areas."
        case .unova:
            return "City routes, bridges, forests, caves, and seasonal areas."
        case .kalos:
            return "Star-shaped region routes, coastal paths, caves, and city hubs."
        case .alola:
            return "Island trials, beaches, meadows, volcano paths, and caves."
        case .galar:
            return "Routes, mines, forests, cities, and Wild Area-style zones."
        case .paldea:
            return "Open provinces, numbered areas, lakes, mountains, and deserts."
        }
    }

    var games: [PokemonGameVersion] {
        switch self {
        case .kanto:
            return games(withIDs: ["red", "blue", "yellow", "firered", "leafgreen", "lets-go-pikachu", "lets-go-eevee"])
        case .johto:
            return games(withIDs: ["gold", "silver", "crystal", "heartgold", "soulsilver"])
        case .hoenn:
            return games(withIDs: ["ruby", "sapphire", "emerald", "omega-ruby", "alpha-sapphire"])
        case .sinnoh:
            return games(withIDs: ["diamond", "pearl", "platinum", "brilliant-diamond", "shining-pearl", "legends-arceus"])
        case .unova:
            return games(withIDs: ["black", "white", "black-2", "white-2"])
        case .kalos:
            return games(withIDs: ["x", "y"])
        case .alola:
            return games(withIDs: ["sun", "moon", "ultra-sun", "ultra-moon"])
        case .galar:
            return games(withIDs: ["sword", "shield"])
        case .paldea:
            return games(withIDs: ["scarlet", "violet"])
        }
    }

    var mapHeight: CGFloat {
        let rowCount = Int(ceil(Double(areas.count) / Double(mapColumnCount)))
        return CGFloat(max(4, rowCount)) * 74
    }

    var mapNodes: [PokemonMapNode] {
        if self == .kanto {
            return kantoMapNodes
        }

        let mapAreas = areas
        let columns = mapColumnCount
        let rows = Int(ceil(Double(mapAreas.count) / Double(columns)))

        return mapAreas.enumerated().map { index, area in
            let row = index / columns
            let rawColumn = index % columns
            let column = row.isMultiple(of: 2) ? rawColumn : columns - 1 - rawColumn

            let connectedAreaIDs = [
                index > 0 ? mapAreas[index - 1].id : nil,
                index < mapAreas.count - 1 ? mapAreas[index + 1].id : nil
            ].compactMap { $0 }

            return PokemonMapNode(
                area: area,
                position: CGPoint(
                    x: (CGFloat(column) + 0.5) / CGFloat(columns),
                    y: (CGFloat(row) + 0.55) / CGFloat(rows)
                ),
                connectedAreaIDs: connectedAreaIDs
            )
        }
    }

    var areas: [PokemonMapArea] {
        switch self {
        case .kanto:
            return kantoMapNodes.map(\.area)
        case .johto:
            return [
                place("New Bark Town", .town, "Starting town in southeast Johto."),
                place("Cherrygrove City", .city, "Coastal city west of New Bark Town."),
                place("Violet City", .city, "First Gym city in northern Johto.")
            ] + numberedRoutes(29...48) + [
                PokemonMapArea(name: "Sprout Tower", kind: .landmark, note: "Violet City tower."),
                PokemonMapArea(name: "Ilex Forest", kind: .forest, note: "Forest between Azalea Town and Goldenrod City."),
                PokemonMapArea(name: "Whirl Islands", kind: .water, note: "Island caves near sea routes."),
                place("Azalea Town", .town, "Town near Slowpoke Well and Ilex Forest."),
                place("Goldenrod City", .city, "Large central Johto city."),
                place("Ecruteak City", .city, "Historic city near towers."),
                place("Olivine City", .city, "Western port city."),
                place("Cianwood City", .city, "Island city across the sea."),
                place("Mahogany Town", .town, "Town near Lake of Rage."),
                place("Blackthorn City", .city, "Dragon-type Gym city."),
                PokemonMapArea(name: "Mt. Silver", kind: .cave, note: "Late-game mountain area.")
            ]
        case .hoenn:
            return [
                place("Littleroot Town", .town, "Starting town in southwest Hoenn."),
                place("Oldale Town", .town, "Small town north of Littleroot."),
                place("Petalburg City", .city, "Norman's Gym city."),
                place("Rustboro City", .city, "Stone city with the first Gym."),
                place("Dewford Town", .town, "Island town near Granite Cave."),
                place("Slateport City", .city, "Busy southern port city."),
                place("Mauville City", .city, "Central Hoenn hub city.")
            ] + numberedRoutes(101...134) + [
                PokemonMapArea(name: "Petalburg Woods", kind: .forest, note: "Forest north of Petalburg City."),
                PokemonMapArea(name: "Granite Cave", kind: .cave, note: "Dewford-area cave."),
                PokemonMapArea(name: "Mt. Chimney", kind: .landmark, note: "Volcanic mountain route hub."),
                place("Lavaridge Town", .town, "Hot spring town near Mt. Chimney."),
                place("Fallarbor Town", .town, "Ash-covered northern town."),
                place("Fortree City", .city, "Treehouse city in eastern Hoenn."),
                place("Lilycove City", .city, "Large eastern coastal city."),
                place("Mossdeep City", .city, "Island city with the space center."),
                place("Sootopolis City", .city, "Crater city reached by water."),
                place("Pacifidlog Town", .town, "Floating town in western sea routes."),
                place("Ever Grande City", .city, "League gateway city."),
                PokemonMapArea(name: "Shoal Cave", kind: .cave, note: "Tide-changing coastal cave.")
            ]
        case .sinnoh:
            return [
                place("Twinleaf Town", .town, "Starting town in southwest Sinnoh."),
                place("Sandgem Town", .town, "Professor Rowan's lab town."),
                place("Jubilife City", .city, "Large early-game city."),
                place("Oreburgh City", .city, "Mining city and first Gym.")
            ] + numberedRoutes(201...230) + [
                PokemonMapArea(name: "Eterna Forest", kind: .forest, note: "Forest west of Eterna City."),
                place("Eterna City", .city, "Historic city by Eterna Forest."),
                place("Hearthome City", .city, "Central contest and Gym city."),
                place("Solaceon Town", .town, "Ranch town near the ruins."),
                place("Veilstone City", .city, "Large eastern city."),
                place("Pastoria City", .city, "Marsh-side Gym city."),
                place("Canalave City", .city, "Port city west of Jubilife."),
                place("Celestic Town", .town, "Historic mountain town."),
                place("Snowpoint City", .city, "Snowy northern Gym city."),
                place("Sunyshore City", .city, "Eastern solar-powered city."),
                PokemonMapArea(name: "Mt. Coronet", kind: .cave, note: "Central mountain crossing Sinnoh."),
                PokemonMapArea(name: "Great Marsh", kind: .water, note: "Pastoria marsh encounter area."),
                PokemonMapArea(name: "Snowpoint Temple", kind: .landmark, note: "Northern temple area.")
            ]
        case .unova:
            return [
                place("Nuvema Town", .town, "Starting town in southeast Unova."),
                place("Accumula Town", .town, "Small town north of Nuvema."),
                place("Striaton City", .city, "Early Gym city."),
                place("Nacrene City", .city, "Museum city near Pinwheel Forest.")
            ] + numberedRoutes(1...23) + [
                PokemonMapArea(name: "Pinwheel Forest", kind: .forest, note: "Forest near Nacrene City."),
                place("Castelia City", .city, "Large harbor metropolis."),
                place("Nimbasa City", .city, "Entertainment city in central Unova."),
                place("Driftveil City", .city, "Western port city."),
                place("Mistralton City", .city, "Airport city."),
                place("Icirrus City", .city, "Wetland city."),
                place("Opelucid City", .city, "Dragon Gym city."),
                place("Lacunosa Town", .town, "Town near Giant Chasm."),
                place("Undella Town", .town, "Eastern resort town."),
                place("Black City", .city, "Version-dependent city."),
                place("White Forest", .forest, "Version-dependent forest."),
                PokemonMapArea(name: "Relic Castle", kind: .landmark, note: "Desert ruin area."),
                PokemonMapArea(name: "Chargestone Cave", kind: .cave, note: "Electric cave route."),
                PokemonMapArea(name: "Victory Road", kind: .cave, note: "League approach area.")
            ]
        case .kalos:
            return [
                place("Vaniville Town", .town, "Starting town in southern Kalos."),
                place("Aquacorde Town", .town, "Small town north of Vaniville."),
                place("Santalune City", .city, "First Gym city.")
            ] + numberedRoutes(2...22) + [
                PokemonMapArea(name: "Santalune Forest", kind: .forest, note: "Early Kalos forest."),
                place("Lumiose City", .city, "Central Kalos metropolis."),
                place("Camphrier Town", .town, "Town near Parfum Palace."),
                place("Ambrette Town", .town, "Coastal fossil town."),
                place("Cyllage City", .city, "Coastal Gym city."),
                place("Geosenge Town", .town, "Stone-lined town."),
                place("Shalour City", .city, "Tower of Mastery city."),
                place("Coumarine City", .city, "Split coastal city."),
                place("Laverre City", .city, "Fairy Gym city."),
                place("Dendemille Town", .town, "Windmill town."),
                place("Anistar City", .city, "Sundial city."),
                place("Snowbelle City", .city, "Snowy forest city."),
                PokemonMapArea(name: "Connecting Cave", kind: .cave, note: "Cave route between towns."),
                PokemonMapArea(name: "Reflection Cave", kind: .cave, note: "Mirror-like cave area."),
                PokemonMapArea(name: "Kalos Power Plant", kind: .landmark, note: "Desert-side facility.")
            ]
        case .alola:
            return [
                place("Iki Town", .town, "Melemele Island town."),
                place("Hau'oli City", .city, "Large city on Melemele Island."),
                place("Heahea City", .city, "Akala Island port city."),
                place("Paniola Town", .town, "Akala ranch town.")
            ] + numberedRoutes(1...17) + [
                PokemonMapArea(name: "Melemele Meadow", kind: .forest, note: "Melemele Island meadow."),
                PokemonMapArea(name: "Brooklet Hill", kind: .water, note: "Akala Island water trial area."),
                place("Konikoni City", .city, "Akala market city."),
                place("Malie City", .city, "Ula'ula Island city."),
                place("Tapu Village", .town, "Ruined village near Mount Lanakila."),
                place("Seafolk Village", .town, "Poni Island floating village."),
                PokemonMapArea(name: "Wela Volcano Park", kind: .landmark, note: "Volcanic trial area."),
                PokemonMapArea(name: "Vast Poni Canyon", kind: .cave, note: "Late-game canyon path.")
            ]
        case .galar:
            return [
                place("Postwick", .town, "Starting village in southern Galar."),
                place("Wedgehurst", .town, "Town by the station and lab."),
                place("Motostoke", .city, "Industrial city and Gym Challenge hub.")
            ] + numberedRoutes(1...10) + [
                PokemonMapArea(name: "Rolling Fields", kind: .field, note: "Wild Area field zone."),
                place("Turffield", .town, "Grass Gym town."),
                place("Hulbury", .city, "Water Gym port city."),
                place("Hammerlocke", .city, "Castle city in central Galar."),
                place("Stow-on-Side", .town, "Historic mural town."),
                place("Ballonlea", .town, "Fairy forest town."),
                place("Circhester", .city, "Snowy spa city."),
                place("Spikemuth", .town, "Dark Gym town."),
                place("Wyndon", .city, "Northern capital city."),
                PokemonMapArea(name: "Glimwood Tangle", kind: .forest, note: "Luminous forest path."),
                PokemonMapArea(name: "Galar Mine", kind: .cave, note: "Mine route area."),
                PokemonMapArea(name: "Lake of Outrage", kind: .water, note: "Wild Area lake zone.")
            ]
        case .paldea:
            return [
                place("Cabo Poco", .town, "Player home area in southern Paldea."),
                place("Los Platos", .town, "First town north of Cabo Poco."),
                place("Mesagoza", .city, "Central academy city."),
                PokemonMapArea(name: "South Province", kind: .field, note: "Southern Paldea province areas."),
                place("Cortondo", .town, "Bug Gym town in the west."),
                place("Artazon", .town, "Grass Gym town in the east."),
                place("Levincia", .city, "Electric Gym city on the east coast."),
                PokemonMapArea(name: "East Province", kind: .field, note: "Eastern Paldea province areas."),
                place("Cascarrafa", .city, "Water Gym city near the desert."),
                PokemonMapArea(name: "West Province", kind: .field, note: "Western Paldea province areas."),
                place("Medali", .city, "Normal Gym city."),
                place("Montenevera", .town, "Ghost Gym town on Glaseado Mountain."),
                place("Alfornada", .town, "Psychic Gym town in the southwest."),
                PokemonMapArea(name: "North Province", kind: .field, note: "Northern Paldea province areas."),
                PokemonMapArea(name: "Casseroya Lake", kind: .water, note: "Large lake in northwest Paldea."),
                PokemonMapArea(name: "Asado Desert", kind: .landmark, note: "Western desert area."),
                PokemonMapArea(name: "Glaseado Mountain", kind: .cave, note: "Snowy mountain region."),
                PokemonMapArea(name: "Area Zero", kind: .landmark, note: "Great Crater expedition area.")
            ]
        }
    }

    private func games(withIDs ids: [String]) -> [PokemonGameVersion] {
        ids.compactMap { id in
            PokemonGameVersion.all.first { $0.id == id }
        }
    }

    private var mapColumnCount: Int {
        switch self {
        case .paldea:
            return 3
        case .galar:
            return 4
        default:
            return 5
        }
    }

    private func numberedRoutes(_ range: ClosedRange<Int>) -> [PokemonMapArea] {
        range.map { number in
            PokemonMapArea(name: "Route \(number)", kind: .route, note: "Regional route area.")
        }
    }

    private var kantoMapNodes: [PokemonMapNode] {
        [
            node("Pallet Town", .town, x: 0.42, y: 0.86, connectedTo: ["Route 1", "Route 21"], note: "Starting town in southwest Kanto."),
            node("Route 1", .route, x: 0.42, y: 0.76, connectedTo: ["Pallet Town", "Viridian City"], note: "Road between Pallet Town and Viridian City."),
            node("Viridian City", .city, x: 0.42, y: 0.66, connectedTo: ["Route 1", "Route 2", "Route 22"], note: "Western Kanto city near Viridian Forest."),
            node("Route 2", .route, x: 0.42, y: 0.55, connectedTo: ["Viridian City", "Viridian Forest", "Pewter City"], note: "North-south route through Viridian Forest."),
            node("Viridian Forest", .forest, x: 0.54, y: 0.52, connectedTo: ["Route 2"], note: "Forest between Viridian City and Pewter City."),
            node("Pewter City", .city, x: 0.42, y: 0.42, connectedTo: ["Route 2", "Route 3"], note: "Rock Gym city near Mt. Moon."),
            node("Route 3", .route, x: 0.56, y: 0.42, connectedTo: ["Pewter City", "Mt. Moon"], note: "Route from Pewter City toward Mt. Moon."),
            node("Mt. Moon", .cave, x: 0.68, y: 0.42, connectedTo: ["Route 3", "Route 4"], note: "Cave between Pewter City and Cerulean City."),
            node("Route 4", .route, x: 0.78, y: 0.42, connectedTo: ["Mt. Moon", "Cerulean City"], note: "Route from Mt. Moon to Cerulean City."),
            node("Cerulean City", .city, x: 0.82, y: 0.32, connectedTo: ["Route 4", "Route 5", "Route 9", "Route 24"], note: "Water Gym city in northern Kanto."),
            node("Route 24", .route, x: 0.82, y: 0.22, connectedTo: ["Cerulean City", "Route 25"], note: "Nugget Bridge north of Cerulean."),
            node("Route 25", .route, x: 0.66, y: 0.18, connectedTo: ["Route 24"], note: "Route toward Bill's house."),
            node("Route 5", .route, x: 0.82, y: 0.44, connectedTo: ["Cerulean City", "Saffron City"], note: "Route south of Cerulean City."),
            node("Saffron City", .city, x: 0.72, y: 0.56, connectedTo: ["Route 5", "Route 6", "Route 7", "Route 8"], note: "Central Kanto city."),
            node("Route 6", .route, x: 0.72, y: 0.68, connectedTo: ["Saffron City", "Vermilion City"], note: "Route from Saffron to Vermilion."),
            node("Vermilion City", .city, x: 0.72, y: 0.80, connectedTo: ["Route 6", "Route 11"], note: "Port city in southern Kanto."),
            node("Route 11", .route, x: 0.84, y: 0.80, connectedTo: ["Vermilion City", "Route 12"], note: "Route east of Vermilion."),
            node("Route 12", .route, x: 0.92, y: 0.70, connectedTo: ["Route 11", "Lavender Town", "Route 13"], note: "North-south coastal route."),
            node("Route 13", .route, x: 0.92, y: 0.82, connectedTo: ["Route 12", "Route 14"], note: "Route toward southern Kanto."),
            node("Route 14", .route, x: 0.84, y: 0.90, connectedTo: ["Route 13", "Route 15"], note: "Route toward Fuchsia City."),
            node("Route 15", .route, x: 0.70, y: 0.92, connectedTo: ["Route 14", "Fuchsia City"], note: "Route east of Fuchsia City."),
            node("Fuchsia City", .city, x: 0.56, y: 0.92, connectedTo: ["Route 15", "Route 18", "Route 19"], note: "Safari Zone city in southern Kanto."),
            node("Route 19", .water, x: 0.54, y: 0.98, connectedTo: ["Fuchsia City", "Seafoam Islands"], note: "Sea route south of Fuchsia."),
            node("Seafoam Islands", .water, x: 0.36, y: 0.98, connectedTo: ["Route 19", "Route 20"], note: "Island cave between Fuchsia and Cinnabar."),
            node("Route 20", .water, x: 0.22, y: 0.96, connectedTo: ["Seafoam Islands", "Cinnabar Island"], note: "Sea route to Cinnabar Island."),
            node("Cinnabar Island", .town, x: 0.18, y: 0.86, connectedTo: ["Route 20", "Route 21"], note: "Volcanic island town."),
            node("Route 21", .water, x: 0.30, y: 0.86, connectedTo: ["Cinnabar Island", "Pallet Town"], note: "Sea route between Cinnabar and Pallet."),
            node("Route 18", .route, x: 0.42, y: 0.90, connectedTo: ["Fuchsia City", "Route 17"], note: "Cycling Road exit near Fuchsia."),
            node("Route 17", .route, x: 0.32, y: 0.76, connectedTo: ["Route 18", "Route 16"], note: "Cycling Road."),
            node("Route 16", .route, x: 0.34, y: 0.62, connectedTo: ["Route 17", "Celadon City"], note: "Route west of Celadon."),
            node("Celadon City", .city, x: 0.50, y: 0.56, connectedTo: ["Route 16", "Route 7"], note: "Large western Kanto city."),
            node("Route 7", .route, x: 0.60, y: 0.56, connectedTo: ["Celadon City", "Saffron City"], note: "Route between Celadon and Saffron."),
            node("Route 8", .route, x: 0.84, y: 0.56, connectedTo: ["Saffron City", "Lavender Town"], note: "Route between Saffron and Lavender."),
            node("Lavender Town", .town, x: 0.94, y: 0.56, connectedTo: ["Route 8", "Rock Tunnel", "Route 12"], note: "Town known for Pokemon Tower."),
            node("Route 9", .route, x: 0.92, y: 0.36, connectedTo: ["Cerulean City", "Rock Tunnel"], note: "Route east of Cerulean."),
            node("Rock Tunnel", .cave, x: 0.98, y: 0.46, connectedTo: ["Route 9", "Lavender Town"], note: "Dark cave route toward Lavender."),
            node("Route 22", .route, x: 0.28, y: 0.66, connectedTo: ["Viridian City", "Route 23"], note: "Route west of Viridian City."),
            node("Route 23", .route, x: 0.18, y: 0.56, connectedTo: ["Route 22", "Victory Road"], note: "League gate route toward Victory Road."),
            node("Victory Road", .cave, x: 0.12, y: 0.44, connectedTo: ["Route 23", "Indigo Plateau"], note: "Cave before the Pokemon League."),
            node("Indigo Plateau", .landmark, x: 0.10, y: 0.32, connectedTo: ["Victory Road"], note: "Pokemon League plateau.")
        ]
    }

    private func place(_ name: String, _ kind: PokemonMapAreaKind, _ note: String) -> PokemonMapArea {
        PokemonMapArea(name: name, kind: kind, note: note)
    }

    private func node(
        _ name: String,
        _ kind: PokemonMapAreaKind,
        x: CGFloat,
        y: CGFloat,
        connectedTo connectedAreaIDs: [String],
        note: String
    ) -> PokemonMapNode {
        PokemonMapNode(
            area: PokemonMapArea(name: name, kind: kind, note: note),
            position: CGPoint(x: x, y: y),
            connectedAreaIDs: connectedAreaIDs
        )
    }
}

private struct PokemonMapNode: Identifiable {
    let area: PokemonMapArea
    let position: CGPoint
    let connectedAreaIDs: [String]

    var id: String {
        area.id
    }
}

private struct PokemonMapConnection: Identifiable, Hashable {
    let id: String
    let startID: String
    let endID: String
}

private struct PokemonMapArea: Identifiable, Hashable {
    let name: String
    let kind: PokemonMapAreaKind
    let note: String

    var id: String {
        name
    }

    var shortName: String {
        name.replacingOccurrences(of: "Route ", with: "R")
    }
}

private enum PokemonMapAreaKind: Hashable {
    case town
    case city
    case route
    case field
    case forest
    case cave
    case water
    case landmark

    var systemImage: String {
        switch self {
        case .town:
            return "house.fill"
        case .city:
            return "building.2.fill"
        case .route:
            return "point.topleft.down.curvedto.point.bottomright.up"
        case .field:
            return "leaf.fill"
        case .forest:
            return "tree.fill"
        case .cave:
            return "mountain.2.fill"
        case .water:
            return "drop.fill"
        case .landmark:
            return "mappin.and.ellipse"
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
