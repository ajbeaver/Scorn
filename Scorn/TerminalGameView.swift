import Foundation
import SwiftUI
internal import Combine

struct TerminalGameView: View {
    @StateObject private var model = ScornGameModel(seed: 734_221)
    @State private var showingItems = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { proxy in
                let metrics = LayoutMetrics(
                    height: proxy.size.height,
                    compactHeight: verticalSizeClass == .compact || proxy.size.height < 700
                )

                VStack(spacing: metrics.stackSpacing) {
                    statusPanel(metrics: metrics)
                        .frame(maxHeight: metrics.statusPanelHeight, alignment: .top)

                    roomPanel(metrics: metrics)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                .padding(.horizontal, metrics.outerHorizontalPadding)
                .padding(.top, metrics.topPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    commandPanel(metrics: metrics)
                        .padding(.horizontal, metrics.outerHorizontalPadding)
                        .padding(.top, metrics.stackSpacing)
                        .background(Color.black)
                }
            }
        }
    }

    private func statusPanel(metrics: LayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Area: \(model.areaName)  Settlement: \(model.settlementName)")
                .font(.system(size: metrics.metaFontSize, weight: .regular, design: .monospaced))
                .foregroundColor(ScornColor.red)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            Text("Passage \(model.passageLabel)  Watch \(model.watchLabel)")
                .font(.system(size: metrics.metaFontSize, weight: .regular, design: .monospaced))
                .foregroundColor(ScornColor.red.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Text(model.statusHeader)
                .font(.system(size: metrics.secondaryFontSize, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
                .minimumScaleFactor(0.88)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(metrics.panelPadding)
        .overlay(Rectangle().stroke(ScornColor.red, lineWidth: 1.2))
    }

    private func roomPanel(metrics: LayoutMetrics) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.locationTitle.uppercased())
                    .font(.system(size: metrics.titleFontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)

                Text(model.locationDescription)
                    .font(.system(size: metrics.bodyFontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(model.conditionCues, id: \.self) { cue in
                    Text(cue)
                        .font(.system(size: metrics.secondaryFontSize, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(model.momentLine)
                    .font(.system(size: metrics.bodyFontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(model.isDead ? ScornColor.red : .white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(model.distantLine)
                    .font(.system(size: metrics.secondaryFontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)

                if showingItems && !model.isDead {
                    Text("You check what is left in your pockets.")
                        .font(.system(size: metrics.secondaryFontSize, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    if model.usableItems.isEmpty {
                        Text("Nothing usable remains.")
                            .font(.system(size: metrics.secondaryFontSize, weight: .regular, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(metrics.panelPadding)
        }
        .scrollIndicators(.hidden)
        .overlay(Rectangle().stroke(ScornColor.red, lineWidth: 1.2))
    }

    private func commandPanel(metrics: LayoutMetrics) -> some View {
        VStack(spacing: metrics.buttonSpacing) {
            if model.isDead {
                MenuButton(title: "Begin Again", compact: metrics.compactHeight) {
                    showingItems = false
                    model.restart()
                }
                MenuButton(title: "Return To Menu", compact: metrics.compactHeight) {
                    onExit()
                }
            } else if showingItems {
                ForEach(model.usableItems, id: \.id) { item in
                    MenuButton(title: "Use \(item.name) x\(item.count)", compact: metrics.compactHeight) {
                        model.use(item: item.id)
                        showingItems = false
                    }
                }

                MenuButton(title: model.usableItems.isEmpty ? "Back" : "Done", compact: metrics.compactHeight) {
                    showingItems = false
                    model.closeItems()
                }
            } else {
                MenuButton(title: "Rest", compact: metrics.compactHeight) {
                    model.rest()
                }

                MenuButton(title: "Search", compact: metrics.compactHeight) {
                    model.search()
                }

                MenuButton(title: "Items", compact: metrics.compactHeight) {
                    showingItems.toggle()
                    if !showingItems {
                        model.closeItems()
                    }
                }

                MenuButton(title: "Next Room", compact: metrics.compactHeight) {
                    model.nextRoom()
                }
            }
        }
    }
}

private struct MenuButton: View {
    let title: String
    let compact: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: compact ? 14 : 15, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, compact ? 7 : 9)
                .overlay(Rectangle().stroke(ScornColor.red, lineWidth: 1.2))
        }
        .buttonStyle(.plain)
    }
}

private struct LayoutMetrics {
    let compactHeight: Bool
    let statusPanelHeight: CGFloat
    let stackSpacing: CGFloat
    let buttonSpacing: CGFloat
    let panelPadding: CGFloat
    let outerHorizontalPadding: CGFloat
    let topPadding: CGFloat
    let metaFontSize: CGFloat
    let titleFontSize: CGFloat
    let bodyFontSize: CGFloat
    let secondaryFontSize: CGFloat

    init(height: CGFloat, compactHeight: Bool) {
        self.compactHeight = compactHeight
        self.stackSpacing = compactHeight ? 9 : 14
        self.buttonSpacing = compactHeight ? 6 : 8
        self.panelPadding = compactHeight ? 8 : 10
        self.outerHorizontalPadding = compactHeight ? 14 : 18
        self.topPadding = compactHeight ? 8 : 12
        self.metaFontSize = compactHeight ? 11.5 : 12.5
        self.titleFontSize = compactHeight ? 14 : 15
        self.bodyFontSize = compactHeight ? 12.5 : 13
        self.secondaryFontSize = compactHeight ? 11.5 : 12.5

        statusPanelHeight = compactHeight ? 86 : 98
    }
}

@MainActor
final class ScornGameModel: ObservableObject {
    @Published private(set) var locationTitle = ""
    @Published private(set) var locationDescription = ""
    @Published private(set) var conditionCues: [String] = []
    @Published private(set) var momentLine = ""
    @Published private(set) var distantLine = ""
    @Published private(set) var passage: Int = 1
    @Published private(set) var watch: Int = 1
    @Published private(set) var isDead = false
    @Published private(set) var playerLegitimacy = 40

    private let seed: UInt64
    private var rng: SeededRNG

    private var world: World
    private var locationsByID: [Int: Location] = [:]
    private var settlementStateByID: [Int: SettlementState] = [:]
    private var globalState = GlobalState(resourceClimate: 50, pressureClimate: 50, entropy: 26)
    private var simTick = 0
    private var autonomousTask: Task<Void, Never>?

    private var currentLocationID: Int
    private var visitCountByLocation: [Int: Int] = [:]
    private var realizedLocations: [Int: RealizedLocation] = [:]

    private var vitality = 58
    private var thirst = 40
    private var hunger = 35
    private var attention = 14

    private var hiddenDrift = 18
    private var wearByLocation: [Int: Int] = [:]

    private var inventory: [ItemID: Int] = [.water: 1, .ration: 1, .bandage: 0, .scrap: 1]

    init(seed: UInt64) {
        self.seed = seed
        self.rng = SeededRNG(seed: seed)

        var generator = WorldGenerator(seed: seed)
        let generated = generator.generate()
        self.world = generated
        self.currentLocationID = generated.startLocationID

        for location in generated.locations {
            locationsByID[location.id] = location
            wearByLocation[location.id] = 46 + Int(stableHash(seed: seed, values: [UInt64(location.id), 99]) % 30)
        }

        initializeSimulationState()
        startAutonomousSimulation()
        restart()
    }

    var passageLabel: String { String(format: "%02d", passage) }
    var watchLabel: String { String(format: "%02d", watch) }
    var areaName: String {
        guard
            let location = locationsByID[currentLocationID],
            let area = world.areasByID[location.areaID]
        else { return "Unknown" }
        return area.name
    }

    var settlementName: String {
        guard
            let location = locationsByID[currentLocationID],
            let settlement = world.settlementsByID[location.settlementID]
        else { return "Unknown" }
        return settlement.name
    }

    var statusHeader: String {
        "Condition: \(conditionBand(for: vitality, kind: .vitality))  Hunger: \(conditionBand(for: hunger, kind: .hunger))  Thirst: \(conditionBand(for: thirst, kind: .thirst))  Legitimacy: \(legitimacyBand)"
    }

    fileprivate var usableItems: [ItemOption] {
        ItemID.allCases.compactMap { item in
            let count = inventory[item, default: 0]
            guard count > 0 else { return nil }
            return ItemOption(id: item, name: item.name, count: count)
        }
    }

    func restart() {
        rng = SeededRNG(seed: seed)
        passage = 1
        watch = 1
        isDead = false

        currentLocationID = world.startLocationID
        visitCountByLocation = [:]
        realizedLocations = [:]

        vitality = 58
        thirst = 40
        hunger = 35
        attention = 14
        hiddenDrift = 18
        playerLegitimacy = 40
        simTick = 0
        globalState = GlobalState(resourceClimate: 50, pressureClimate: 50, entropy: 26)
        initializeSimulationState()

        inventory = [.water: 1, .ration: 1, .bandage: 0, .scrap: 1]

        for location in world.locations {
            wearByLocation[location.id] = 46 + Int(stableHash(seed: seed, values: [UInt64(location.id), 99]) % 30)
        }

        momentLine = "You wake cold, with grit between your teeth."
        distantLine = "Somewhere beyond the walls, water keeps time."
        enterCurrentLocation(incrementVisit: true)
        startAutonomousSimulation()
    }

    func closeItems() {
        momentLine = "You let your pockets fall still."
    }

    func rest() {
        guard !isDead else { return }

        tick(timeCost: 2, baseRisk: 8)
        applyPlayerInfluence(.rest)

        vitality += 10
        thirst += 5
        hunger += 5

        if randomPercent() < 22 + hiddenDrift / 10 {
            vitality -= 7
            momentLine = "You drift, then wake hard at movement just outside the dark."
        } else {
            momentLine = "You rest in short breaths. The room stays watchful."
        }

        attention += 2
        refreshNarrative()
        evaluateMortality()
    }

    func search() {
        guard !isDead else { return }

        tick(timeCost: 1, baseRisk: 10)

        guard let location = locationsByID[currentLocationID] else { return }
        let wearPenalty = max(0, (44 - wearByLocation[currentLocationID, default: 50]) / 4)
        let hazardChance = 12 + hiddenDrift / 3 + wearPenalty
        let findChance = max(35, 72 - hiddenDrift / 2)

        let roll = randomPercent()

        if roll < hazardChance {
            vitality -= 6 + Int(rng.nextInt(max: 6))
            applyPlayerInfluence(.search(risky: true))
            if location.kind.isExterior {
                momentLine = "Loose stone slips beneath you. You catch yourself too late."
            } else {
                momentLine = "A shelf gives way in your hands. Splinters rake your palm."
            }
        } else if roll < hazardChance + findChance {
            let found = weightedFoundItem(for: location)
            gain(found, amount: 1)
            applyPlayerInfluence(.search(risky: false))
            momentLine = found.searchLine(for: location.kind)
        } else {
            applyPlayerInfluence(.search(risky: true))
            momentLine = location.kind.isExterior
                ? "You search the open ground and come up with dust and old nails."
                : "You turn the room over and find nothing worth carrying."
        }

        wearByLocation[currentLocationID, default: 50] = max(0, wearByLocation[currentLocationID, default: 50] - Int(rng.nextInt(max: 3)))
        refreshNarrative()
        evaluateMortality()
    }

    func nextRoom() {
        guard !isDead else { return }
        guard let current = locationsByID[currentLocationID] else { return }
        guard !current.neighbors.isEmpty else {
            momentLine = "The way onward has narrowed to broken stone."
            refreshNarrative()
            return
        }

        tick(timeCost: 2, baseRisk: 11)
        applyPlayerInfluence(.travel)

        let destination = chooseNeighbor(from: current.neighbors)
        currentLocationID = destination
        enterCurrentLocation(incrementVisit: true)

        if randomPercent() < 19 + hiddenDrift / 12 {
            vitality -= 5
            momentLine = "You push through and scrape skin on rough concrete."
        } else {
            momentLine = "You move on before the air can settle behind you."
        }

        refreshNarrative()
        evaluateMortality()
    }

    fileprivate func use(item: ItemID) {
        guard !isDead else { return }
        guard consume(item, amount: 1) else {
            momentLine = "You reach for it and find nothing left."
            return
        }

        tick(timeCost: 1, baseRisk: 4)
        applyPlayerInfluence(.use(item))

        switch item {
        case .water:
            thirst -= 22
            momentLine = "You drink slowly, saving the last swallow."
        case .ration:
            hunger -= 19
            momentLine = "You chew in silence until your hands steady."
        case .bandage:
            vitality += 14
            momentLine = "You bind the wound and wait for the sting to fade."
        case .scrap:
            if randomPercent() < 38 {
                gain(.bandage, amount: 1)
                momentLine = "You shape cloth and scrap into a rough binding."
            } else {
                momentLine = "The scrap twists uselessly in your grip."
            }
        }

        refreshNarrative()
        evaluateMortality()
    }

    private func enterCurrentLocation(incrementVisit: Bool) {
        if incrementVisit {
            visitCountByLocation[currentLocationID, default: 0] += 1
        }

        _ = realizeLocationIfNeeded(currentLocationID)
        refreshNarrative()
        refreshConditionCues()
    }

    private func refreshNarrative() {
        guard let location = locationsByID[currentLocationID] else {
            locationTitle = "Unknown"
            locationDescription = "Stone and shadow keep their own counsel here."
            return
        }

        let visits = visitCountByLocation[currentLocationID, default: 1]
        let driftBand = driftBandValue
        let realized = realizeLocationIfNeeded(currentLocationID)

        locationTitle = location.name
        locationDescription = descriptionText(
            location: location,
            realized: realized,
            visitCount: visits,
            driftBand: driftBand
        )

        if randomPercent() < 42 {
            distantLine = distantWhisper(around: location, driftBand: driftBand)
        }

        refreshConditionCues()
    }

    private func refreshConditionCues() {
        guard locationsByID[currentLocationID] != nil else {
            conditionCues = []
            return
        }

        var criticalBodyCue: String?
        if vitality < 24 {
            criticalBodyCue = "Your hands will not stay steady."
        } else if thirst > 78 {
            criticalBodyCue = "Your throat is raw with thirst."
        } else if hunger > 82 {
            criticalBodyCue = "Hunger bends your focus into a narrow line."
        }

        var criticalWorldCue: String?
        let wear = wearByLocation[currentLocationID, default: 50]
        if wear < 22 {
            criticalWorldCue = "Dust keeps dropping from the seams overhead."
        }

        conditionCues = [criticalBodyCue, criticalWorldCue].compactMap { $0 }
    }

    private func descriptionText(location: Location, realized: RealizedLocation, visitCount: Int, driftBand: Int) -> String {
        let area = world.areasByID[location.areaID]!
        let settlement = world.settlementsByID[location.settlementID]!
        let wear = wearByLocation[location.id, default: 50]

        let firstLine: String
        if visitCount <= 1 {
            let areaColor = pick(areaLexicon[area.type]!.textures, locationID: location.id, salt: 1)
            switch location.kind {
            case .structure(let structureType):
                let structureRole = pick(structureLexicon[structureType]!.roles, locationID: location.id, salt: 4)
                firstLine = "\(location.name) is a \(structureRole) in \(settlement.name), all \(areaColor) edges and \(realized.sensoryLead)."
            case .exterior(let exteriorType):
                let exteriorRole = pick(exteriorLexicon[exteriorType]!.roles, locationID: location.id, salt: 5)
                firstLine = "\(location.name) is a \(exteriorRole) through \(areaColor) stone, where \(realized.sensoryLead)."
            }
        } else {
            let recognition = pick(revisitRecognition, locationID: location.id, salt: 6 + visitCount)
            firstLine = "Back in \(location.name), \(recognition)."
        }

        var sentences: [String] = [firstLine]
        if visitCount > 1 || driftBand > 1 || wear < 30 {
            sentences.append(subtleShiftLine(for: location.id, driftBand: driftBand, wear: wear))
        }
        if let localState = settlementStateByID[location.settlementID] {
            sentences.append(settlementStateDescription(localState))
        }

        return sentences.prefix(2).joined(separator: " ")
    }

    private func subtleShiftLine(for locationID: Int, driftBand: Int, wear: Int) -> String {
        if wear < 20 {
            return pick([
                "The place feels one hard noise away from giving.",
                "Cracks you missed before now hold the eye.",
                "A faint crumble answers each step."
            ], locationID: locationID, salt: 30)
        }

        if driftBand > 1 {
            return pick([
                "It feels narrower than memory allows.",
                "Something in the room has tightened.",
                "The quiet here has sharpened."
            ], locationID: locationID, salt: 31)
        }

        switch wear {
        case ..<16:
            return pick([
                "The walls answer back in hollow tones.",
                "Fractures run under the plaster like veins.",
                "The floor carries a fragile echo."
            ], locationID: locationID, salt: 30)
        case ..<34:
            return pick([
                "Grit has gathered where the floor sags.",
                "Mortar dust hangs in the corners.",
                "The seams look newly opened."
            ], locationID: locationID, salt: 31)
        default:
            return pick([
                "The room holds, but only just.",
                "For now, the frame keeps its shape.",
                "It stands by habit more than trust."
            ], locationID: locationID, salt: 33)
        }
    }

    private func settlementStateDescription(_ state: SettlementState) -> String {
        let material: String
        switch state.resourceStability {
        case ..<30: material = "stores run thin"
        case ..<60: material = "supplies move in tight cycles"
        default: material = "storage lines hold for now"
        }

        let social: String
        switch state.morale {
        case ..<32: social = "faces stay guarded"
        case ..<62: social = "people measure each word"
        default: social = "voices carry a cautious warmth"
        }
        return "In the settlement, \(material) and \(social)."
    }

    private func distantWhisper(around location: Location, driftBand: Int) -> String {
        let local = realizeLocationIfNeeded(location.id)
        let nearbySettlement = world.settlementsByID[location.settlementID]!
        let mood = pick(driftLexicon[driftBand]!.distantMoods, locationID: location.id, salt: 42 + passage)
        let place = pick(settlementLexicon[nearbySettlement.type]!.distantPlaces, locationID: location.id, salt: 43)
        return "\(mood) from \(place), then quiet again near \(local.memoryMark). \(settlementContextLine(settlementID: location.settlementID))"
    }

    private func tick(timeCost: Int, baseRisk: Int) {
        advanceTime(by: timeCost)
        worldDrift(timeCost: timeCost)
        bodyDrift(cost: timeCost)
        immediateDanger(baseRisk: baseRisk)
    }

    private func advanceTime(by amount: Int) {
        let total = (passage - 1) * 6 + (watch - 1) + amount
        passage = total / 6 + 1
        watch = total % 6 + 1
    }

    private func worldDrift(timeCost: Int) {
        runAutonomousWorldSimulation(pulses: max(1, timeCost))

        let passes = 1 + Int(rng.nextInt(max: 3))
        for _ in 0..<passes {
            let index = Int(rng.nextInt(max: UInt64(world.locations.count)))
            let id = world.locations[index].id
            let wearFloor = max(4, Int(settlementWearFloor(for: id)))
            wearByLocation[id, default: 50] = max(wearFloor, wearByLocation[id, default: 50] - Int(rng.nextInt(max: 3)))
        }
    }

    private func bodyDrift(cost: Int) {
        thirst += cost * (3 + Int(rng.nextInt(max: 2)))
        hunger += cost * (2 + Int(rng.nextInt(max: 2)))

        if thirst > 55 { vitality -= (thirst - 55) / 7 }
        if hunger > 58 { vitality -= (hunger - 58) / 9 }

        vitality -= Int(rng.nextInt(max: 2))
        clampVitals()
    }

    private func immediateDanger(baseRisk: Int) {
        let wearPenalty = max(0, (45 - wearByLocation[currentLocationID, default: 50]) / 5)
        let driftPenalty = hiddenDrift / 8
        let danger = max(0, baseRisk + wearPenalty + driftPenalty + attention / 10)

        if randomPercent() < danger {
            vitality -= 4 + Int(rng.nextInt(max: 7))
            if randomPercent() < 50 {
                momentLine = "A hard sound snaps close by; you flinch and hit stone."
            } else {
                momentLine = "Something shifts overhead, and dust rains over your shoulders."
            }
        }

        clampVitals()
    }

    private func evaluateMortality() {
        clampVitals()

        if vitality <= 0 {
            isDead = true
            momentLine = "You sink to the floor and cannot rise again."
            return
        }

        if thirst >= 100 {
            isDead = true
            momentLine = "Your lips split, your vision narrows, and the dark wins."
            return
        }

        if hunger >= 100 && randomPercent() < 40 {
            isDead = true
            momentLine = "Your knees give way, and the cold takes the rest."
        }
    }

    private func chooseNeighbor(from neighbors: [Int]) -> Int {
        let weighted = neighbors.map { id in
            let visits = visitCountByLocation[id, default: 0]
            return (id: id, weight: max(1, 5 - visits))
        }

        let totalWeight = weighted.reduce(0) { $0 + $1.weight }
        var roll = Int(rng.nextInt(max: UInt64(totalWeight)))

        for entry in weighted {
            if roll < entry.weight {
                return entry.id
            }
            roll -= entry.weight
        }

        return neighbors[0]
    }

    private func weightedFoundItem(for location: Location) -> ItemID {
        let pool: [(ItemID, Int)]

        switch location.kind {
        case .structure(let type):
            switch type {
            case .pumpWorks:
                pool = [(.water, 5), (.ration, 2), (.bandage, 2), (.scrap, 4)]
            case .storeRoom:
                pool = [(.water, 2), (.ration, 5), (.bandage, 2), (.scrap, 3)]
            case .barracks:
                pool = [(.water, 2), (.ration, 3), (.bandage, 4), (.scrap, 3)]
            case .workshop:
                pool = [(.water, 1), (.ration, 2), (.bandage, 2), (.scrap, 6)]
            case .chapel:
                pool = [(.water, 2), (.ration, 2), (.bandage, 5), (.scrap, 2)]
            }
        case .exterior:
            pool = [(.water, 2), (.ration, 2), (.bandage, 1), (.scrap, 5)]
        }

        let total = pool.reduce(0) { $0 + $1.1 }
        var roll = Int(rng.nextInt(max: UInt64(total)))
        for entry in pool {
            if roll < entry.1 { return entry.0 }
            roll -= entry.1
        }
        return .scrap
    }

    private func realizeLocationIfNeeded(_ id: Int) -> RealizedLocation {
        if let existing = realizedLocations[id] {
            return existing
        }

        guard let location = locationsByID[id] else {
            let fallback = RealizedLocation(sensoryLead: "The air tastes of old stone.", memoryMark: "the dark corner")
            realizedLocations[id] = fallback
            return fallback
        }

        let settlement = world.settlementsByID[location.settlementID]!

        let sensory: String
        switch location.kind {
        case .structure(let structureType):
            let structureImage = pick(structureLexicon[structureType]!.sensory, locationID: id, salt: 71)
            sensory = structureImage.lowercased().trimmingCharacters(in: .punctuationCharacters)
        case .exterior(let exteriorType):
            let exteriorImage = pick(exteriorLexicon[exteriorType]!.sensory, locationID: id, salt: 73)
            sensory = exteriorImage.lowercased().trimmingCharacters(in: .punctuationCharacters)
        }

        let mark = pick(settlementLexicon[settlement.type]!.marks, locationID: id, salt: 74)
        let result = RealizedLocation(sensoryLead: sensory, memoryMark: mark)
        realizedLocations[id] = result
        return result
    }

    private var driftBandValue: Int {
        let pressure = Int(currentSettlementState?.factionPressure ?? Double(hiddenDrift))
        switch max(hiddenDrift, pressure) {
        case ..<30: return 0
        case ..<58: return 1
        default: return 2
        }
    }

    private var legitimacyBand: String {
        switch playerLegitimacy {
        case ..<25: return "shunned"
        case ..<45: return "uncertain"
        case ..<70: return "known"
        default: return "trusted"
        }
    }

    private var currentSettlementState: SettlementState? {
        guard let location = locationsByID[currentLocationID] else { return nil }
        return settlementStateByID[location.settlementID]
    }

    private func initializeSimulationState() {
        settlementStateByID = [:]
        for settlement in world.settlements {
            settlementStateByID[settlement.id] = SettlementState(
                resourceStability: 40 + Double(rng.nextInt(max: 36)),
                infrastructureDurability: 45 + Double(rng.nextInt(max: 32)),
                morale: 35 + Double(rng.nextInt(max: 38)),
                factionPressure: 30 + Double(rng.nextInt(max: 40)),
                leader: nil
            )
        }
    }

    private func startAutonomousSimulation() {
        autonomousTask?.cancel()
        autonomousTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !self.isDead else { continue }
                self.runAutonomousWorldSimulation(pulses: 1)
                if self.randomPercent() < 35 {
                    self.refreshNarrative()
                }
            }
        }
    }

    private func runAutonomousWorldSimulation(pulses: Int) {
        guard !world.settlements.isEmpty else { return }

        for _ in 0..<max(1, pulses) {
            simTick += 1
            var nextStates = settlementStateByID

            for settlement in world.settlements {
                guard var local = settlementStateByID[settlement.id] else { continue }
                let neighborStates = world.settlementLinks[settlement.id, default: []].compactMap { settlementStateByID[$0] }
                let neighbor = aggregate(neighborStates)
                let turbulence = (Double(Int(rng.nextInt(max: 201))) - 100.0) / 100.0
                let systemicPulse = sin(Double(simTick + settlement.id) * 0.21) * 1.2

                updateLeaderIfNeeded(settlementID: settlement.id, state: &local)
                let leaderBias = local.leader?.bias ?? SettlementBias.zero

                local.resourceStability += (52 + globalState.resourceClimate * 0.12 - local.resourceStability) * 0.08
                local.resourceStability += (neighbor.resourceStability - local.resourceStability) * 0.12
                local.resourceStability += leaderBias.resource + turbulence * 0.6 + systemicPulse * 0.4

                local.infrastructureDurability += (55 - local.infrastructureDurability) * 0.06
                local.infrastructureDurability += (neighbor.infrastructureDurability - local.infrastructureDurability) * 0.1
                local.infrastructureDurability += leaderBias.infrastructure + turbulence * 0.4

                local.factionPressure += (globalState.pressureClimate - local.factionPressure) * 0.07
                local.factionPressure += (neighbor.factionPressure - local.factionPressure) * 0.14
                local.factionPressure += leaderBias.pressure + max(0, 60 - local.resourceStability) * 0.04
                local.factionPressure += max(0, 58 - local.infrastructureDurability) * 0.03 + turbulence * 0.7

                local.morale += (50 - local.morale) * 0.05
                local.morale += (neighbor.morale - local.morale) * 0.1
                local.morale += leaderBias.morale
                local.morale += (local.resourceStability - 50) * 0.03
                local.morale -= max(0, local.factionPressure - 55) * 0.05
                local.morale += turbulence * 0.5

                nextStates[settlement.id] = clampSettlementState(local)
            }

            settlementStateByID = nextStates

            globalState.resourceClimate += (50 - globalState.resourceClimate) * 0.03 + (Double(Int(rng.nextInt(max: 11))) - 5) * 0.18
            globalState.pressureClimate += (52 - globalState.pressureClimate) * 0.03 + (Double(Int(rng.nextInt(max: 13))) - 6) * 0.2
            globalState.entropy += (28 - globalState.entropy) * 0.04 + (Double(Int(rng.nextInt(max: 9))) - 4) * 0.28

            globalState.resourceClimate = clamp(globalState.resourceClimate, min: 8, max: 92)
            globalState.pressureClimate = clamp(globalState.pressureClimate, min: 8, max: 92)
            globalState.entropy = clamp(globalState.entropy, min: 6, max: 95)
        }

        if let current = currentSettlementState {
            hiddenDrift = min(100, Int((current.factionPressure * 0.58) + (globalState.entropy * 0.42)))
        } else {
            hiddenDrift = min(100, max(12, hiddenDrift))
        }
    }

    private func aggregate(_ states: [SettlementState]) -> SettlementState {
        guard !states.isEmpty else {
            return SettlementState(resourceStability: 50, infrastructureDurability: 50, morale: 50, factionPressure: 50, leader: nil)
        }

        let count = Double(states.count)
        return SettlementState(
            resourceStability: states.reduce(0) { $0 + $1.resourceStability } / count,
            infrastructureDurability: states.reduce(0) { $0 + $1.infrastructureDurability } / count,
            morale: states.reduce(0) { $0 + $1.morale } / count,
            factionPressure: states.reduce(0) { $0 + $1.factionPressure } / count,
            leader: nil
        )
    }

    private func updateLeaderIfNeeded(settlementID: Int, state: inout SettlementState) {
        if var leader = state.leader {
            leader.tenure += 1
            leader.influence += (abs(state.morale - state.factionPressure) > 18 ? 0.8 : -0.4)
            leader.influence = clamp(leader.influence, min: 0, max: 100)
            if leader.influence < 6 && randomPercent() < 45 {
                state.leader = nil
            } else {
                state.leader = leader
            }
            return
        }

        let instability = (state.factionPressure - state.morale) + max(0, 45 - state.resourceStability) * 0.5
        let emergenceChance = Int(clamp(instability * 0.22, min: 2, max: 22))
        if randomPercent() >= emergenceChance { return }

        let archetype: LeaderArchetype
        switch Int(rng.nextInt(max: 3)) {
        case 0: archetype = .warden
        case 1: archetype = .broker
        default: archetype = .oracle
        }

        state.leader = EmergentLeader(
            name: emergentLeaderName(for: settlementID, archetype: archetype),
            archetype: archetype,
            influence: 32 + Double(rng.nextInt(max: 35)),
            tenure: 1,
            bias: archetype.bias
        )
    }

    private func emergentLeaderName(for settlementID: Int, archetype: LeaderArchetype) -> String {
        let pool: [String]
        switch archetype {
        case .warden:
            pool = ["Mara Ironwatch", "The Gate Warden", "Knuckle Ward", "Sable Keeper"]
        case .broker:
            pool = ["Vey Ledger", "Nailhand Broker", "Tallow Voice", "Iris of Debts"]
        case .oracle:
            pool = ["Ash Cantor", "The Lamp Witness", "Votive Hush", "Sister Emberline"]
        }
        return pool[Int(stableHash(seed: seed, values: [UInt64(settlementID), UInt64(simTick), 701]) % UInt64(pool.count))]
    }

    private func clampSettlementState(_ state: SettlementState) -> SettlementState {
        var result = state
        result.resourceStability = clamp(result.resourceStability, min: 8, max: 92)
        result.infrastructureDurability = clamp(result.infrastructureDurability, min: 8, max: 92)
        result.morale = clamp(result.morale, min: 8, max: 92)
        result.factionPressure = clamp(result.factionPressure, min: 8, max: 92)
        if var leader = result.leader {
            leader.influence = clamp(leader.influence, min: 0, max: 100)
            result.leader = leader
        }
        return result
    }

    private func settlementWearFloor(for locationID: Int) -> Double {
        guard let settlementID = locationsByID[locationID]?.settlementID, let state = settlementStateByID[settlementID] else {
            return 4
        }
        return clamp(12 + state.infrastructureDurability * 0.24 - globalState.entropy * 0.1, min: 4, max: 42)
    }

    private func settlementContextLine(settlementID: Int) -> String {
        guard let state = settlementStateByID[settlementID] else { return "" }

        let pressureTone: String
        switch state.factionPressure {
        case ..<33: pressureTone = "The faction lines feel diffuse tonight."
        case ..<60: pressureTone = "Pressure holds at a muttered simmer."
        default: pressureTone = "Faction pressure is climbing, taut and public."
        }

        if let leader = state.leader, leader.influence > 24 {
            return "\(pressureTone) \(leader.name) pulls local decisions \(leader.archetype.voice)."
        }
        return pressureTone
    }

    private func applyPlayerInfluence(_ action: PlayerAction) {
        guard let location = locationsByID[currentLocationID], var state = settlementStateByID[location.settlementID] else { return }

        var legitimacyDelta = 0
        switch action {
        case .rest:
            state.morale += 0.8
            state.factionPressure -= 0.6
            legitimacyDelta = state.factionPressure > 58 ? 1 : 0
        case .travel:
            state.factionPressure += 0.5
            state.infrastructureDurability -= 0.2
        case .search(let risky):
            state.resourceStability -= risky ? 1.4 : 0.6
            state.infrastructureDurability -= risky ? 0.8 : 0.3
            state.factionPressure += risky ? 1.2 : 0.5
            legitimacyDelta = risky ? -1 : 1
        case .use(let item):
            switch item {
            case .water:
                state.resourceStability -= 0.3
                legitimacyDelta = -1
            case .ration:
                state.resourceStability -= 0.5
                legitimacyDelta = -1
            case .bandage:
                state.morale += 1.1
                legitimacyDelta = 1
            case .scrap:
                state.infrastructureDurability += 0.6
                legitimacyDelta = 1
            }
        }

        settlementStateByID[location.settlementID] = clampSettlementState(state)
        playerLegitimacy = min(100, max(0, playerLegitimacy + legitimacyDelta))
    }

    private func clamp(_ value: Double, min minimum: Double, max maximum: Double) -> Double {
        Swift.min(Swift.max(value, minimum), maximum)
    }

    private func consume(_ item: ItemID, amount: Int) -> Bool {
        let current = inventory[item, default: 0]
        guard current >= amount else { return false }
        inventory[item] = current - amount
        return true
    }

    private func gain(_ item: ItemID, amount: Int) {
        inventory[item, default: 0] += amount
    }

    private func randomPercent() -> Int {
        Int(rng.nextInt(max: 100))
    }

    private func pick(_ options: [String], locationID: Int, salt: Int) -> String {
        guard !options.isEmpty else { return "" }
        let index = Int(stableHash(seed: seed, values: [
            UInt64(locationID),
            UInt64(salt),
            UInt64(max(1, visitCountByLocation[locationID, default: 1])),
            UInt64(driftBandValue),
            UInt64(passage)
        ]) % UInt64(options.count))
        return options[index]
    }

    private func conditionBand(for value: Int, kind: ConditionKind) -> String {
        switch kind {
        case .vitality:
            switch value {
            case ..<20: return "fading"
            case ..<40: return "worn"
            case ..<65: return "strained"
            default: return "steady"
            }
        case .hunger:
            switch value {
            case ..<35: return "quiet"
            case ..<55: return "present"
            case ..<75: return "sharp"
            default: return "gnawing"
            }
        case .thirst:
            switch value {
            case ..<35: return "quiet"
            case ..<55: return "dry"
            case ..<75: return "parched"
            default: return "burning"
            }
        }
    }

    private func clampVitals() {
        vitality = min(max(vitality, 0), 100)
        thirst = min(max(thirst, 0), 100)
        hunger = min(max(hunger, 0), 100)
        attention = min(max(attention, 0), 100)
    }

    deinit {
        autonomousTask?.cancel()
    }
}

private struct RealizedLocation {
    let sensoryLead: String
    let memoryMark: String
}

private enum ItemID: String, CaseIterable {
    case water
    case ration
    case bandage
    case scrap

    var name: String {
        switch self {
        case .water: return "Water"
        case .ration: return "Ration"
        case .bandage: return "Bandage"
        case .scrap: return "Scrap"
        }
    }

    func searchLine(for kind: LocationKind) -> String {
        switch (self, kind.isExterior) {
        case (.water, true): return "Under broken piping, you find a canteen with a little water left."
        case (.water, false): return "You find water pooled in a clean jar and keep what you can."
        case (.ration, true): return "A sealed ration turns up beneath windblown cloth."
        case (.ration, false): return "In a warped drawer, you find food that still passes for safe."
        case (.bandage, true): return "Cloth caught on wire still serves as binding."
        case (.bandage, false): return "A dry box hides strips of cloth and old salve."
        case (.scrap, true): return "You gather bent metal and pocket the least corroded pieces."
        case (.scrap, false): return "You pull useful scrap from under collapsed shelving."
        }
    }
}

private struct ItemOption: Identifiable {
    let id: ItemID
    let name: String
    let count: Int
}

private enum ConditionKind {
    case vitality
    case hunger
    case thirst
}

private enum PlayerAction {
    case rest
    case search(risky: Bool)
    case travel
    case use(ItemID)
}

private struct SettlementState {
    var resourceStability: Double
    var infrastructureDurability: Double
    var morale: Double
    var factionPressure: Double
    var leader: EmergentLeader?
}

private struct GlobalState {
    var resourceClimate: Double
    var pressureClimate: Double
    var entropy: Double
}

private struct SettlementBias {
    let resource: Double
    let infrastructure: Double
    let morale: Double
    let pressure: Double

    static let zero = SettlementBias(resource: 0, infrastructure: 0, morale: 0, pressure: 0)
}

private struct EmergentLeader {
    let name: String
    let archetype: LeaderArchetype
    var influence: Double
    var tenure: Int
    let bias: SettlementBias
}

private enum LeaderArchetype {
    case warden
    case broker
    case oracle

    var bias: SettlementBias {
        switch self {
        case .warden:
            return SettlementBias(resource: -0.15, infrastructure: 0.35, morale: -0.05, pressure: 0.45)
        case .broker:
            return SettlementBias(resource: 0.4, infrastructure: 0.1, morale: 0.2, pressure: 0.1)
        case .oracle:
            return SettlementBias(resource: -0.05, infrastructure: -0.1, morale: 0.45, pressure: 0.25)
        }
    }

    var voice: String {
        switch self {
        case .warden: return "through enforcement"
        case .broker: return "through trade bargains"
        case .oracle: return "through ritual authority"
        }
    }
}

private struct World {
    let areas: [Area]
    let settlements: [Settlement]
    let structures: [Structure]
    let rooms: [Room]
    let locations: [Location]
    let settlementLinks: [Int: [Int]]
    let startLocationID: Int

    var areasByID: [Int: Area] {
        Dictionary(uniqueKeysWithValues: areas.map { ($0.id, $0) })
    }

    var settlementsByID: [Int: Settlement] {
        Dictionary(uniqueKeysWithValues: settlements.map { ($0.id, $0) })
    }

    var structuresByID: [Int: Structure] {
        Dictionary(uniqueKeysWithValues: structures.map { ($0.id, $0) })
    }

    var roomsByID: [Int: Room] {
        Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })
    }
}

private struct Area {
    let id: Int
    let name: String
    let type: AreaType
    let settlementIDs: [Int]
}

private struct Settlement {
    let id: Int
    let name: String
    let type: SettlementType
    let areaID: Int
    let locationIDs: [Int]
    let structureIDs: [Int]
    let hubLocationID: Int
}

private struct Structure {
    let id: Int
    let name: String
    let type: StructureType
    let areaID: Int
    let settlementID: Int
    let anchorLocationID: Int
    let roomIDs: [Int]
}

private struct Room {
    let id: Int
    let name: String
    let areaID: Int
    let settlementID: Int
    let structureID: Int
}

private struct Location {
    let id: Int
    let name: String
    let areaID: Int
    let settlementID: Int
    let kind: LocationKind
    var neighbors: [Int]
}

private enum LocationKind {
    case structure(StructureType)
    case exterior(ExteriorType)

    var isExterior: Bool {
        if case .exterior = self { return true }
        return false
    }
}

private enum AreaType: CaseIterable {
    case floodworks
    case quarryBelt
    case ashTerrace
}

private enum SettlementType: CaseIterable {
    case scavengerWard
    case cisternCamp
    case shrineQuarter
}

private enum StructureType: CaseIterable {
    case pumpWorks
    case storeRoom
    case barracks
    case workshop
    case chapel
}

private enum ExteriorType: CaseIterable {
    case lane
    case yard
    case catwalk
    case stair
}

private struct AreaLexicon {
    let textures: [String]
    let sensory: [String]
}

private struct SettlementLexicon {
    let rhythm: [String]
    let marks: [String]
    let distantPlaces: [String]
}

private struct StructureLexicon {
    let roles: [String]
    let sensory: [String]
}

private struct ExteriorLexicon {
    let roles: [String]
    let sensory: [String]
}

private struct DriftLexicon {
    let tones: [String]
    let distantMoods: [String]
}

private let areaLexicon: [AreaType: AreaLexicon] = [
    .floodworks: AreaLexicon(
        textures: ["wet", "salt-stained", "water-darkened"],
        sensory: [
            "Moist air clings to your skin.",
            "A mineral chill sits low against the floor.",
            "The smell of standing water never quite lifts."
        ]
    ),
    .quarryBelt: AreaLexicon(
        textures: ["chalky", "dust-gray", "quarried"],
        sensory: [
            "Fine grit rasps at the back of your throat.",
            "Stone dust softens every edge in the light.",
            "The air tastes dry and faintly metallic."
        ]
    ),
    .ashTerrace: AreaLexicon(
        textures: ["smoke-bruised", "ash-pale", "char-streaked"],
        sensory: [
            "Warm soot settles along your sleeves.",
            "A burnt tang lingers in each breath.",
            "Air currents carry a brittle heat."
        ]
    )
]

private let settlementLexicon: [SettlementType: SettlementLexicon] = [
    .scavengerWard: SettlementLexicon(
        rhythm: ["Tin shutters knock in uneven bursts", "Loose chains answer each other across alleys", "Footsteps pass quickly and avoid lingering"],
        marks: ["the flaked paint at the corner post", "the dented rain barrel", "the faded chalk line near the wall"],
        distantPlaces: ["the scavenger lanes", "the old trade corner", "the tarped roofs"]
    ),
    .cisternCamp: SettlementLexicon(
        rhythm: ["Water drips somewhere just out of sight", "Buckets knock in patient intervals", "Voices keep low around stored water"],
        marks: ["the rope-wrapped railing", "the cracked cistern lip", "the patched canvas windbreak"],
        distantPlaces: ["the cistern edge", "the pump queue", "the water stairs"]
    ),
    .shrineQuarter: SettlementLexicon(
        rhythm: ["Murmured vows rise and fade behind stone", "Candles are replaced before they burn out", "Cloth pennants whisper in shallow drafts"],
        marks: ["the soot-dark lintel", "the wax-streaked step", "the carved niche by the door"],
        distantPlaces: ["the prayer walk", "the shrine yard", "the lamp alcove"]
    )
]

private let structureLexicon: [StructureType: StructureLexicon] = [
    .pumpWorks: StructureLexicon(
        roles: ["pump hall", "waterworks chamber", "valve room"],
        sensory: ["Cold vapor gathers near your ankles.", "Pipe joints click with slow pressure changes.", "Damp metal smells linger under old grease."]
    ),
    .storeRoom: StructureLexicon(
        roles: ["store room", "supply lockup", "ration hold"],
        sensory: ["Rotting wood and dry cloth share the air.", "Shelving leans with uneven weight.", "Every drawer sticks before it yields."]
    ),
    .barracks: StructureLexicon(
        roles: ["sleep barrack", "shared bunk room", "watch shelter"],
        sensory: ["Old blankets hold a stale human warmth.", "Frames creak even when untouched.", "The room smells of rusted buckles and soap ash."]
    ),
    .workshop: StructureLexicon(
        roles: ["repair workshop", "tool room", "maker's bay"],
        sensory: ["Metal filings glitter in cracks and seams.", "Oil darkens the grain of every workbench.", "Broken handles collect in corners like kindling."]
    ),
    .chapel: StructureLexicon(
        roles: ["small chapel", "prayer room", "ritual hall"],
        sensory: ["Wax and dust soften the air.", "Stone niches hold blackened candle roots.", "Whispers seem to linger after mouths close."]
    )
]

private let exteriorLexicon: [ExteriorType: ExteriorLexicon] = [
    .lane: ExteriorLexicon(
        roles: ["narrow lane", "tight passage", "winding cut"],
        sensory: ["Wind threads through it in short, cold pulls.", "Loose gravel chatters under each step.", "Shadows stretch long between wall breaks."]
    ),
    .yard: ExteriorLexicon(
        roles: ["open yard", "broken court", "cleared pocket"],
        sensory: ["Open air makes every noise carry farther.", "Puddles catch dim light like dark mirrors.", "Footprints overlap until none can be trusted."]
    ),
    .catwalk: ExteriorLexicon(
        roles: ["raised catwalk", "swaying bridge", "narrow overpass"],
        sensory: ["Boards flex under your weight.", "A draft rises from below and chills your legs.", "Nails complain softly in the planks."]
    ),
    .stair: ExteriorLexicon(
        roles: ["stone stair", "switchback stair", "broken steps"],
        sensory: ["Dust slips down each tread before you do.", "The handrail feels colder than the air.", "Echoes fall away beneath your feet."]
    )
]

private let revisitRecognition = [
    "the place answers before your eyes fully adjust",
    "your body remembers where the floor pitches",
    "you catch yourself tracing the same lines in the wall"
]

private let driftLexicon: [Int: DriftLexicon] = [
    0: DriftLexicon(
        tones: ["wary", "hushed", "held in check"],
        distantMoods: ["Muted voices carry", "A bucket knocks twice", "A low argument rises briefly"]
    ),
    1: DriftLexicon(
        tones: ["uneasy", "thinner", "strained"],
        distantMoods: ["A shout breaks and fades", "Running steps pass overhead", "Something heavy is dragged across stone"]
    ),
    2: DriftLexicon(
        tones: ["frayed", "close to breaking", "raw and exposed"],
        distantMoods: ["A sharp cry echoes and dies", "Rapid footsteps scatter in more than one direction", "A long scrape rings out, then silence"]
    )
]

private struct WorldGenerator {
    private let seed: UInt64
    private var rng: SeededRNG

    init(seed: UInt64) {
        self.seed = seed
        self.rng = SeededRNG(seed: seed)
    }

    mutating func generate() -> World {
        let areaCount = 2 + Int(rng.nextInt(max: 2))

        var areaPool = AreaType.allCases
        stableShuffle(&areaPool)

        var settlementPool = SettlementType.allCases
        stableShuffle(&settlementPool)

        var structurePool = StructureType.allCases
        stableShuffle(&structurePool)

        var exteriorPool = ExteriorType.allCases
        stableShuffle(&exteriorPool)

        var areas: [Area] = []
        var settlements: [Settlement] = []
        var structures: [Structure] = []
        var rooms: [Room] = []
        var locations: [Location] = []

        var locationByID: [Int: Location] = [:]

        var nextAreaID = 1
        var nextSettlementID = 1
        var nextLocationID = 1
        var nextStructureID = 1
        var nextRoomID = 1

        var areaHubByArea: [Int: Int] = [:]
        var settlementLinkSets: [Int: Set<Int>] = [:]

        for areaIndex in 0..<areaCount {
            let areaID = nextAreaID
            nextAreaID += 1

            let areaType = areaPool[areaIndex % areaPool.count]
            let areaName = areaName(for: areaType, areaID: areaID)

            let settlementCount = 2 + Int(rng.nextInt(max: 2))
            var settlementIDs: [Int] = []

            var previousSettlementHub: Int?
            var previousSettlementID: Int?

            for settlementIndex in 0..<settlementCount {
                let settlementID = nextSettlementID
                nextSettlementID += 1

                settlementIDs.append(settlementID)

                let settlementType = settlementPool[(settlementIndex + areaIndex) % settlementPool.count]
                let settlementName = settlementName(for: settlementType, areaID: areaID, settlementID: settlementID)

                var settlementLocationIDs: [Int] = []
                var settlementStructureIDs: [Int] = []

                let hubID = nextLocationID
                nextLocationID += 1
                let hubType = exteriorPool[(settlementIndex + areaIndex) % exteriorPool.count]
                let hubName = hubName(for: settlementType, type: hubType, hubID: hubID)

                let hub = Location(
                    id: hubID,
                    name: hubName,
                    areaID: areaID,
                    settlementID: settlementID,
                    kind: .exterior(hubType),
                    neighbors: []
                )

                settlementLocationIDs.append(hubID)
                locations.append(hub)
                locationByID[hubID] = hub

                let structureCount = 2 + Int(rng.nextInt(max: 2))
                var previousConnectorID: Int?

                for structureIndex in 0..<structureCount {
                    let structureID = nextLocationID
                    nextLocationID += 1

                    let structureType = structurePool[(structureIndex + settlementIndex + areaIndex) % structurePool.count]
                    let structureName = structureName(for: structureType, structureID: structureID)

                    let structure = Location(
                        id: structureID,
                        name: structureName,
                        areaID: areaID,
                        settlementID: settlementID,
                        kind: .structure(structureType),
                        neighbors: []
                    )

                    settlementLocationIDs.append(structureID)
                    locations.append(structure)
                    locationByID[structureID] = structure

                    let structureNodeID = nextStructureID
                    nextStructureID += 1
                    let roomCount = 1 + Int(rng.nextInt(max: 2))
                    var roomIDs: [Int] = []
                    for roomIndex in 0..<roomCount {
                        let roomID = nextRoomID
                        nextRoomID += 1
                        roomIDs.append(roomID)
                        rooms.append(Room(
                            id: roomID,
                            name: roomName(for: structureType, roomID: roomID, roomIndex: roomIndex),
                            areaID: areaID,
                            settlementID: settlementID,
                            structureID: structureNodeID
                        ))
                    }
                    structures.append(Structure(
                        id: structureNodeID,
                        name: structureName,
                        type: structureType,
                        areaID: areaID,
                        settlementID: settlementID,
                        anchorLocationID: structureID,
                        roomIDs: roomIDs
                    ))
                    settlementStructureIDs.append(structureNodeID)

                    let connectorID = nextLocationID
                    nextLocationID += 1

                    let connectorType = exteriorPool[(structureIndex + areaIndex + 1) % exteriorPool.count]
                    let connectorName = connectorName(for: connectorType, connectorID: connectorID)

                    let connector = Location(
                        id: connectorID,
                        name: connectorName,
                        areaID: areaID,
                        settlementID: settlementID,
                        kind: .exterior(connectorType),
                        neighbors: []
                    )

                    settlementLocationIDs.append(connectorID)
                    locations.append(connector)
                    locationByID[connectorID] = connector

                    addEdge(a: hubID, b: connectorID, map: &locationByID)
                    addEdge(a: connectorID, b: structureID, map: &locationByID)

                    if let previousConnectorID {
                        addEdge(a: previousConnectorID, b: connectorID, map: &locationByID)
                    }

                    previousConnectorID = connectorID
                }

                if let previousSettlementHub {
                    let transitID = nextLocationID
                    nextLocationID += 1

                    let transitType = exteriorPool[(settlementIndex + areaIndex + 2) % exteriorPool.count]
                    let transitName = transitName(for: transitType, transitID: transitID, betweenSettlements: true)

                    let transit = Location(
                        id: transitID,
                        name: transitName,
                        areaID: areaID,
                        settlementID: settlementID,
                        kind: .exterior(transitType),
                        neighbors: []
                    )

                    settlementLocationIDs.append(transitID)
                    locations.append(transit)
                    locationByID[transitID] = transit

                    addEdge(a: previousSettlementHub, b: transitID, map: &locationByID)
                    addEdge(a: transitID, b: hubID, map: &locationByID)
                    if let previousSettlementID {
                        settlementLinkSets[previousSettlementID, default: []].insert(settlementID)
                        settlementLinkSets[settlementID, default: []].insert(previousSettlementID)
                    }
                }

                previousSettlementHub = hubID
                previousSettlementID = settlementID

                settlements.append(Settlement(
                    id: settlementID,
                    name: settlementName,
                    type: settlementType,
                    areaID: areaID,
                    locationIDs: settlementLocationIDs,
                    structureIDs: settlementStructureIDs,
                    hubLocationID: hubID
                ))
            }

            if let firstHub = settlements.last(where: { $0.areaID == areaID })?.hubLocationID {
                areaHubByArea[areaID] = firstHub
            }

            areas.append(Area(id: areaID, name: areaName, type: areaType, settlementIDs: settlementIDs))
        }

        if areas.count > 1 {
            for idx in 0..<(areas.count - 1) {
                let left = areas[idx]
                let right = areas[idx + 1]

                guard let leftHub = areaHubByArea[left.id], let rightHub = areaHubByArea[right.id] else { continue }

                let bridgeID = nextLocationID
                nextLocationID += 1

                let bridgeType = ExteriorType.allCases[(idx + Int(seed % 3)) % ExteriorType.allCases.count]
                let bridge = Location(
                    id: bridgeID,
                    name: transitName(for: bridgeType, transitID: bridgeID, betweenSettlements: false),
                    areaID: left.id,
                    settlementID: settlements.first(where: { $0.areaID == left.id })?.id ?? settlements[0].id,
                    kind: .exterior(bridgeType),
                    neighbors: []
                )

                locations.append(bridge)
                locationByID[bridgeID] = bridge
                addEdge(a: leftHub, b: bridgeID, map: &locationByID)
                addEdge(a: bridgeID, b: rightHub, map: &locationByID)
                if
                    let leftSettlementID = locationByID[leftHub]?.settlementID,
                    let rightSettlementID = locationByID[rightHub]?.settlementID
                {
                    settlementLinkSets[leftSettlementID, default: []].insert(rightSettlementID)
                    settlementLinkSets[rightSettlementID, default: []].insert(leftSettlementID)
                }
            }
        }

        for index in locations.indices {
            if let updated = locationByID[locations[index].id] {
                locations[index] = updated
            }
        }

        let startLocationID = settlements.first?.hubLocationID ?? locations.first?.id ?? 1
        let settlementLinks = settlementLinkSets.mapValues { Array($0).sorted() }

        return World(
            areas: areas,
            settlements: settlements,
            structures: structures,
            rooms: rooms,
            locations: locations,
            settlementLinks: settlementLinks,
            startLocationID: startLocationID
        )
    }

    private mutating func stableShuffle<T>(_ values: inout [T]) {
        guard values.count > 1 else { return }
        for idx in values.indices.dropLast().reversed() {
            let j = Int(rng.nextInt(max: UInt64(idx + 1)))
            values.swapAt(idx, j)
        }
    }

    private func addEdge(a: Int, b: Int, map: inout [Int: Location]) {
        var left = map[a]!
        if !left.neighbors.contains(b) { left.neighbors.append(b) }
        map[a] = left

        var right = map[b]!
        if !right.neighbors.contains(a) { right.neighbors.append(a) }
        map[b] = right
    }

    private func areaName(for type: AreaType, areaID: Int) -> String {
        let pool: [String]
        switch type {
        case .floodworks:
            pool = ["The Drowned Margin", "Salt Lantern Reach", "Undertide Span", "Sluice Hollow"]
        case .quarryBelt:
            pool = ["Chalkbone Verge", "Whitecut Belt", "Dustline Expanse", "Stonewake Reach"]
        case .ashTerrace:
            pool = ["Cinder Terrace", "Ember Shelf", "Smokefall Rise", "Blackwind Steps"]
        }
        return semanticPick(pool, id: areaID, salt: 11)
    }

    private func settlementName(for type: SettlementType, areaID: Int, settlementID: Int) -> String {
        let pool: [String]
        switch type {
        case .scavengerWard:
            pool = ["Tinward", "Ragmarket", "Scraphearth", "Patchline Ward", "Hooklight Quarter"]
        case .cisternCamp:
            pool = ["Cistern Hold", "Bucketline Camp", "Wellgate", "Dampcourt", "Reservoir Row"]
        case .shrineQuarter:
            pool = ["Lampward", "Ash Chapel Quarter", "Votive Court", "Quiet Reliquary", "Candlewalk"]
        }
        return semanticPick(pool, id: settlementID ^ (areaID << 8), salt: 17)
    }

    private func structureName(for type: StructureType, structureID: Int) -> String {
        let pool: [String]
        switch type {
        case .pumpWorks:
            pool = ["Valve Hall", "Pressure House", "Sump Engine", "Cold Pump Room"]
        case .storeRoom:
            pool = ["Ration Vault", "Dry Store", "Provision Lockup", "Tin Pantry"]
        case .barracks:
            pool = ["Watch Barracks", "Bunk Hall", "Night Shelter", "Guard Sleeproom"]
        case .workshop:
            pool = ["Maker's Shed", "Iron Bench", "Repair Loft", "Tool Annex"]
        case .chapel:
            pool = ["Low Chapel", "Hush Nave", "Votive Hall", "Soot Shrine"]
        }
        return semanticPick(pool, id: structureID, salt: 23)
    }

    private func roomName(for type: StructureType, roomID: Int, roomIndex: Int) -> String {
        let pool: [String]
        switch type {
        case .pumpWorks:
            pool = ["Pressure Gallery", "Valve Duct", "Drain Chamber"]
        case .storeRoom:
            pool = ["Ration Rack", "Dry Alcove", "Tin Locker"]
        case .barracks:
            pool = ["Bunk Nook", "Watch Cot", "Blanket Bay"]
        case .workshop:
            pool = ["Bench Bay", "Parts Alcove", "Tool Cage"]
        case .chapel:
            pool = ["Votive Cell", "Quiet Pew", "Lamp Annex"]
        }
        return "\(semanticPick(pool, id: roomID ^ (roomIndex << 4), salt: 24)) \(roomIndex + 1)"
    }

    private func hubName(for settlementType: SettlementType, type: ExteriorType, hubID: Int) -> String {
        let thematic: [String]
        switch settlementType {
        case .scavengerWard:
            thematic = ["Trade Court", "Scrap Cross", "Hook Yard", "Salvage Gate"]
        case .cisternCamp:
            thematic = ["Water Court", "Cistern Edge", "Bucket Steps", "Well Mouth"]
        case .shrineQuarter:
            thematic = ["Prayer Walk", "Lamp Court", "Candle Gate", "Votive Yard"]
        }

        let byExterior: [String]
        switch type {
        case .lane: byExterior = ["Lane", "Pass", "Walk"]
        case .yard: byExterior = ["Yard", "Court", "Square"]
        case .catwalk: byExterior = ["Catwalk", "Overway", "High Walk"]
        case .stair: byExterior = ["Stairs", "Steps", "Rise"]
        }

        let base = semanticPick(thematic, id: hubID, salt: 29)
        let tail = semanticPick(byExterior, id: hubID, salt: 30)
        return "\(base) \(tail)"
    }

    private func connectorName(for type: ExteriorType, connectorID: Int) -> String {
        let pool: [String]
        switch type {
        case .lane:
            pool = ["Narrow Cut", "Dust Lane", "Blind Passage", "Wire Alley"]
        case .yard:
            pool = ["Broken Yard", "Open Court", "Shale Yard", "Wind Pocket"]
        case .catwalk:
            pool = ["High Catwalk", "Sway Bridge", "Rafter Walk", "Narrow Overway"]
        case .stair:
            pool = ["Switchback Stairs", "Stone Steps", "Split Stair", "Drop Stair"]
        }
        return semanticPick(pool, id: connectorID, salt: 37)
    }

    private func transitName(for type: ExteriorType, transitID: Int, betweenSettlements: Bool) -> String {
        let interSettlementPool: [String]
        switch type {
        case .lane:
            interSettlementPool = ["Long Lane", "Crossline Passage", "Narrow Throughway", "Far Lane"]
        case .yard:
            interSettlementPool = ["Open Crossing", "Middle Yard", "Worn Court", "Hollow Crossing"]
        case .catwalk:
            interSettlementPool = ["Span Catwalk", "Crossbeam Walk", "Long Overpass", "Ridge Walk"]
        case .stair:
            interSettlementPool = ["Traverse Stairs", "Between Steps", "Climb Passage", "Split Rise"]
        }

        let interAreaPool: [String]
        switch type {
        case .lane:
            interAreaPool = ["Boundary Lane", "Edge Passage", "Farthrough", "Border Walk"]
        case .yard:
            interAreaPool = ["Boundary Court", "Open Verge", "Border Yard", "Drift Court"]
        case .catwalk:
            interAreaPool = ["Spine Catwalk", "Ridge Span", "Border Overway", "Long Span Walk"]
        case .stair:
            interAreaPool = ["Boundary Stairs", "Ridge Steps", "Edge Rise", "Border Climb"]
        }

        return semanticPick(
            betweenSettlements ? interSettlementPool : interAreaPool,
            id: transitID,
            salt: betweenSettlements ? 41 : 43
        )
    }

    private func semanticPick(_ pool: [String], id: Int, salt: Int) -> String {
        guard !pool.isEmpty else { return "Unnamed Place" }
        let index = Int(stableHash(seed: seed, values: [
            UInt64(id),
            UInt64(salt),
            UInt64(seed & 0xffff)
        ]) % UInt64(pool.count))
        return pool[index]
    }
}

private func stableHash(seed: UInt64, values: [UInt64]) -> UInt64 {
    var state = seed ^ 0x9e37_79b9_7f4a_7c15
    for value in values {
        var z = value &+ 0x9e37_79b9_7f4a_7c15 &+ state
        z = (z ^ (z >> 30)) &* 0xbf58_476d_1ce4_e5b9
        z = (z ^ (z >> 27)) &* 0x94d0_49bb_1331_11eb
        z = z ^ (z >> 31)
        state ^= z &+ 0x517c_c1b7_2722_0a95
        state = (state << 13) | (state >> 51)
    }
    return state
}

private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9e37_79b9_7f4a_7c15 : seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1442695040888963407
        return state
    }

    mutating func nextInt(max: UInt64) -> UInt64 {
        guard max > 0 else { return 0 }
        return next() % max
    }
}
