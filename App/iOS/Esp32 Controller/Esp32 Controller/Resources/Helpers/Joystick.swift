import SwiftUI

struct JoystickView: View {
    var onSend: (String) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var lastCommand: String = ""
    @State private var timer: Timer? = nil

    @State private var pendingX: CGFloat = 0
    @State private var pendingY: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 150)

            Circle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let maxRadius: CGFloat = 60
                            let clamped = CGSize(
                                width: min(max(value.translation.width, -maxRadius), maxRadius),
                                height: min(max(value.translation.height, -maxRadius), maxRadius)
                            )
                            dragOffset = clamped

                            pendingX = clamped.width / maxRadius
                            pendingY = -clamped.height / maxRadius // y up is forward

                            startDebounceTimer()
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            pendingX = 0
                            pendingY = 0
                            let stopCommand = "V:0 R:32768"
                            sendCommand(stopCommand)
                            stopDebounceTimer()
                        }
                )
        }
    }

    // MARK: - Command Calculation

    func calculateRoombaCommand(x: CGFloat, y: CGFloat) -> String {
        var x = -x  // flip for natural joystick control
        var y = y

        // Deadzones
        if abs(x) < 0.05 { x = 0 }
        if abs(y) < 0.05 { y = 0 }

        // 1. Velocity from Y (forward/back)
        let velocity = min(max(Int(y * 500), -500), 500)

        // 2. Radius from X (tight turn when X is strong)
        let radius: Int

        if x == 0 {
            radius = 32768 // straight
        } else {
            // Full X = radius ±100 (tight)
            // Half X = radius ±500 (medium)
            // Low X = radius ±1000 (wide)
            let turnTightness = 1 - abs(x) // 0 (tight) to 1 (gentle)
            let curveRadius = Int(100 + turnTightness * 900) // 100–1000

            radius = x < 0 ? -curveRadius : curveRadius
        }

        return "V:\(velocity) R:\(radius)"
    }





    // MARK: - Debounce Timer

    func startDebounceTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let cmd = calculateRoombaCommand(x: pendingX, y: pendingY)
                sendCommand(cmd)
            }
        }
    }

    func stopDebounceTimer() {
        timer?.invalidate()
        timer = nil
    }

    func sendCommand(_ command: String) {
        if command != lastCommand {
            lastCommand = command
            print("📤 Sending debounced: \(command)")
            onSend(command)
        }
    }
}
