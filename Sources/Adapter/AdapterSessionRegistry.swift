import Foundation

struct AdapterSessionRegistry {
    struct Assignment {
        let clientId: Int
        let role: TetrisAIRole
        let controllerClientId: Int?
    }

    private struct Session {
        let clientId: Int
        let joinOrder: Int
        let controllerEligible: Bool
        let streamsObservations: Bool
        var role: TetrisAIRole
        var lastSequence: Int
    }

    private var sessions: [UUID: Session] = [:]
    private var controller: UUID?
    private var nextClientId = 1

    var observationTargets: [UUID] {
        sessions.compactMap { $0.value.streamsObservations ? $0.key : nil }
    }

    func contains(_ connection: UUID) -> Bool {
        sessions[connection] != nil
    }

    func isController(_ connection: UUID) -> Bool {
        controller == connection
    }

    mutating func register(
        _ connection: UUID,
        requestedRole: TetrisAIRole,
        streamsObservations: Bool
    ) -> Assignment {
        let clientId = nextClientId
        nextClientId += 1
        let controllerEligible = requestedRole != .observer
        let role: TetrisAIRole
        if controller == nil, controllerEligible {
            controller = connection
            role = .controller
        } else {
            role = .observer
        }
        sessions[connection] = Session(
            clientId: clientId,
            joinOrder: clientId,
            controllerEligible: controllerEligible,
            streamsObservations: streamsObservations,
            role: role,
            lastSequence: 1
        )
        return Assignment(
            clientId: clientId,
            role: role,
            controllerClientId: controller.flatMap { sessions[$0]?.clientId }
        )
    }

    mutating func accept(sequence: Int, from connection: UUID) -> Bool {
        guard var session = sessions[connection], sequence > session.lastSequence else {
            return false
        }
        session.lastSequence = sequence
        sessions[connection] = session
        return true
    }

    mutating func claim(_ connection: UUID) -> Bool {
        guard var session = sessions[connection] else { return false }
        guard controller == nil else { return controller == connection }
        controller = connection
        session.role = .controller
        sessions[connection] = session
        return true
    }

    mutating func release(_ connection: UUID) -> Bool {
        guard controller == connection, var session = sessions[connection] else { return false }
        controller = nil
        session.role = .observer
        sessions[connection] = session
        return true
    }

    mutating func disconnect(_ connection: UUID) {
        sessions.removeValue(forKey: connection)
        guard controller == connection else { return }
        controller = nil
        guard let promoted = sessions
            .filter({ $0.value.controllerEligible })
            .min(by: { $0.value.joinOrder < $1.value.joinOrder })?
            .key,
              var session = sessions[promoted]
        else { return }
        controller = promoted
        session.role = .controller
        sessions[promoted] = session
    }
}
