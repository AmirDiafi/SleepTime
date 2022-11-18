//
//  BetterRestML.swift
//  more
//
//  Created by Amir Diafi on 11/15/22.
//

import CoreML
import SwiftUI

struct BetterRestML: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        let cal = Calendar.current.date(from: components) ?? Date.now
        return cal
    }
    
    var body: some View {
        List {
            //MARK: WakeUp
            Section("When do you want to wake up?") {
                DatePicker(
                    "Please select a time",
                    selection: $wakeUp,
                    displayedComponents: .hourAndMinute
                )
                
            }
            //MARK: Sleep
            Section("Desired amount of sleep") {
                Stepper(
                    "\(sleepAmount.formatted()) hours",
                    value: $sleepAmount,
                    in: 4...8,
                    step: 0.5
                )
            }
            //MARK: Coffee
            Section("Daily coffee intake") {
                Stepper(
                    "\(coffeeAmount) cop\(coffeeAmount>1 ? "s" : "")",
                    value: $coffeeAmount,
                    in: 1...10
                )
            }
        }
        .navigationTitle("BetterRest")
        .toolbar {
            Button("Calculate", action: calculateBedTime)
        }
        .alert(
            alertTitle,
            isPresented: $showAlert) {
                Button("Got it") {}
            } message: {
                Text(alertMessage)
            }

    }
    
    /// Calculate the bed time from the inputs the user provided
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let allTime = Double(hour + minute)
            
            let prediction = try model.prediction(
                wake: allTime,
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bed time is.."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time."
        }
        showAlert = true
    }
}

struct BetterRestML_Previews: PreviewProvider {
    static var previews: some View {
        BetterRestML()
    }
}
