//
//  ToyViewModel.swift
//  DragGesture_SwiftUI
//
//  Created by Pedro Rojas on 08/01/22.
//

import SwiftUI

class ToyViewModel: ObservableObject {
    @Published var isDragged = false
    @Published var highlighedId: Int?
    @Published var selectedId: Int?
    @Published var showAlert = false
    @Published var currentPosition = initialPosition
    @Published var currentToy: Toy?
    @Published var draggableObjectScale: CGFloat = 1.0


    @Published var secondsElapsed = 0.0
    var timer = Timer()
    var record: Double?

    private var toys = Array(Toy.all.shuffled().prefix(upTo: 3))
    @Published var containerToys = Toy.all.shuffled()

    private static let initialPosition = CGPoint(
        x: UIScreen.main.bounds.midX,
        y: UIScreen.main.bounds.maxY - 100
    )

    private var frames: [Int: CGRect] = [:]
    private(set) var attempts = 0

    func setupGame() {
        currentToy = toys.popLast()
        startTimer()
    }

    func startTimer() {
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.secondsElapsed += 0.1
        }
    }

    func gameOver() {
        timer.invalidate()
        saveRecord()
        showAlert = true
    }

    func saveRecord() {
        guard let record = record else {
            self.record = secondsElapsed
            return
        }

        self.record = min(secondsElapsed, record)
    }

    func update(frame: CGRect, for id: Int) {
        frames[id] = frame
    }

    func update(dragLocation: CGPoint) {
        currentPosition = dragLocation
        for (id, frame) in frames where frame.contains(dragLocation) {
            highlighedId = id
            return
        }

        highlighedId = nil
    }

    func update(isDragged: Bool){
        self.isDragged = isDragged
        guard isDragged == false else { return }
        defer { self.highlighedId = nil }

        withAnimation {
            guard let highlighedId = self.highlighedId else {
                currentPosition = ToyViewModel.initialPosition
                return
            }

            if highlighedId == currentToy?.id {
                selectedId = highlighedId
                guard let frame = frames[highlighedId] else { return }
                currentPosition = CGPoint(x: frame.midX, y: frame.midY)
                draggableObjectScale = 0
                nextGame()
            } else {
                currentPosition = ToyViewModel.initialPosition
            }

            attempts += 1
        }
    }

    func isHighlighted(id: Int) -> Bool {
        return highlighedId == id
    }

    func restart() {
        withAnimation {
            containerToys.shuffle()
        }

        withAnimation(.none) {
            currentPosition = ToyViewModel.initialPosition

            withAnimation {
                draggableObjectScale = 1
            }
        }

        selectedId = nil
    }

    func nextGame() {
        currentToy = toys.popLast()

        if currentToy == nil {
            gameOver()
        } else {
            restart()
        }
    }

    func generateNewGame() {
        toys = Array(Toy.all.shuffled().prefix(upTo: 3))
        attempts = 0
        startTimer()
        nextGame()
    }
}
