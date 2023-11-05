//
//  ContentView.swift
//  BetterRest
//
//  Created by Joel Lacerda on 29/10/23.
//

import CoreML
import Foundation
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmout: TimeInterval = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("When do you want to wake up?") {
                    DatePicker("Wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmout.formatted()) hours", value: $sleepAmout, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    HStack {
                        Spacer()
                        Picker("Cups of coffee", selection: $coffeeAmount) {
                            ForEach(1..<21) { number in
                                Text("^[\(number) cups](inflect:true)")
                            }
                        }
                    }
                }
                
                Section("Suggested time of sleep") {
                    Text(calculateBedTime())
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("BetterRest")
            
        }
    }
    
    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmout, coffee: Int64(coffeeAmount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
           
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}
