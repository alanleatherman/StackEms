import Foundation
import RealityKit
import os

private let logger = Logger(subsystem: "com.stackems", category: "MatchCoordinator")

@Observable
final class MatchCoordinator {
    private let matchState: MatchState
    private let matchInteractor: MatchInteractor
    private var countdownTask: Task<Void, Never>?
    private var matchTimerTask: Task<Void, Never>?
    private var matchObserver: Any?
    private var blockCountObserver: Any?

    var countdownText: String?

    init(matchState: MatchState, matchInteractor: MatchInteractor) {
        self.matchState = matchState
        self.matchInteractor = matchInteractor
    }

    func startCountdown() {
        // Prevent double-calling if already running
        guard countdownTask == nil else {
            logger.info("startCountdown called but already running, skipping")
            return
        }

        logger.info("startCountdown: phase=\(String(describing: self.matchState.phase))")
        WinConditionSystem.matchEndedFired = false
        countdownText = "3"

        countdownTask = Task { @MainActor in
            for i in stride(from: 3, through: 1, by: -1) {
                countdownText = "\(i)"
                logger.info("Countdown: \(i)")
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else {
                    logger.info("Countdown cancelled at \(i)")
                    return
                }
            }
            countdownText = "GO!"
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else {
                logger.info("Countdown cancelled at GO")
                return
            }
            countdownText = nil
            beginCombat()
        }
    }

    private func beginCombat() {
        logger.info("beginCombat: setting phase to .combat")
        matchInteractor.beginCombat()
        startMatchTimer()
        observeMatchNotifications()
    }

    private func startMatchTimer() {
        logger.info("startMatchTimer: phase=\(String(describing: self.matchState.phase))")
        matchTimerTask = Task { @MainActor in
            logger.info("Timer task started, phase=\(String(describing: self.matchState.phase))")
            while !Task.isCancelled && matchState.phase == .combat {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else {
                    logger.info("Timer task cancelled")
                    return
                }
                matchState.matchTimer += 0.1

                if matchState.matchTimer >= GameConfiguration.Match.maxMatchDuration {
                    logger.info("Match timeout reached")
                    endMatchByTimeout()
                    return
                }
            }
            logger.info("Timer task exited loop, cancelled=\(Task.isCancelled), phase=\(String(describing: self.matchState.phase))")
        }
    }

    private func observeMatchNotifications() {
        logger.info("Setting up notification observers")

        blockCountObserver = NotificationCenter.default.addObserver(
            forName: .blockCountUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let playerBlocks = notification.userInfo?["playerBlocks"] as? Int,
                  let opponentBlocks = notification.userInfo?["opponentBlocks"] as? Int else { return }
            Task { @MainActor in
                self.matchState.playerBlocksRemaining = playerBlocks
                self.matchState.opponentBlocksRemaining = opponentBlocks
            }
        }

        matchObserver = NotificationCenter.default.addObserver(
            forName: .matchEnded,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let playerWon = notification.userInfo?["playerWon"] as? Bool else { return }
            logger.info("matchEnded notification received, playerWon=\(playerWon)")
            Task { @MainActor in
                self.stopTimers()
                self.matchInteractor.endMatch(playerWon: playerWon)
            }
        }
    }

    private func endMatchByTimeout() {
        stopTimers()
        let playerWon = matchState.playerBlocksRemaining >= matchState.opponentBlocksRemaining
        logger.info("endMatchByTimeout: playerWon=\(playerWon)")
        matchInteractor.endMatch(playerWon: playerWon)
    }

    func stopTimers() {
        logger.info("stopTimers called")
        countdownTask?.cancel()
        countdownTask = nil
        matchTimerTask?.cancel()
        matchTimerTask = nil
        if let observer = matchObserver {
            NotificationCenter.default.removeObserver(observer)
            matchObserver = nil
        }
        if let observer = blockCountObserver {
            NotificationCenter.default.removeObserver(observer)
            blockCountObserver = nil
        }
    }

    deinit {
        MainActor.assumeIsolated {
            stopTimers()
        }
    }
}
