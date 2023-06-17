//
//  ContentView.swift
//  Edutainment
//
//  Created by Faly RAKOTOMAHARO on 17/06/2023.
//

import SwiftUI

struct AppImage: View {
    var isAnimating: Bool
    var animationDegree: Int
    
    var body: some View {
        HStack {
            Image("bear")
                .rotationAnimation(state: isAnimating, angle: animationDegree, axisValue: (x: 0, y: 1, z: 0))
            Image("panda")
                .rotationAnimation(state: isAnimating, angle: animationDegree, axisValue: (x: 1, y: 0, z: 0))
            Image("hippo")
                .rotationAnimation(state: isAnimating, angle: animationDegree, axisValue: (x: 0, y: 0, z: 1))
        }
    }
}

struct OpacityAnimationModifier: ViewModifier {
    var isAnimating: Bool
    var delay: Double
    var opacity: Double
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? opacity : 0)
            .animation(.easeInOut(duration: 1).delay(delay), value: isAnimating)
    }
}

struct Rotate3DAnimationModifier: ViewModifier {
    var isAnimating: Bool
    var animationDegree: Int
    var axisValue: (x: CGFloat, y: CGFloat, z: CGFloat)
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(Double(animationDegree)), axis: axisValue)
            .animation(.interpolatingSpring(stiffness: 5, damping: 1).repeatForever(), value: isAnimating)
    }
}

extension View {
    func opacityAnimation(state: Bool, delay: Double, opacity: Double) -> some View{
        modifier(OpacityAnimationModifier(isAnimating: state, delay: delay, opacity: opacity))
    }
    
    func rotationAnimation(state: Bool, angle: Int, axisValue: (x: CGFloat, y: CGFloat, z: CGFloat)) -> some View {
        modifier(Rotate3DAnimationModifier(isAnimating: state, animationDegree: angle, axisValue: axisValue))
    }
}

struct ContentView: View {
    //MARK: - PROPERTIES
    @State private var leftNumber = 0
    @State private var rightNumber = 0
    @State private var result = ""
    @State private var showingAlert = false
    @State private var titleAlert = ""
    @State private var messageAlert = ""
    @State private var numberOfQuestionStepper = 5
    @State private var score = 0
    @State private var currentGameNumber = 0
    @State private var showingEnfGameAlert = false
    @FocusState private var isFocusedResultTextField: Bool
    @State private var isDisabledButton = false
    
    @State private var isAnimating = false
    @State private var delay = 0.0
    @State private var animationDegree = 0
    @State private var opacity = 1.0
    
    var isEndGame: Bool {
        numberOfQuestionStepper == currentGameNumber
    }
    var isGoodAnswer: Bool {
        Int(result) == (leftNumber * rightNumber)
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    //MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    AppImage(isAnimating: isAnimating, animationDegree: animationDegree)
                    
                    Section {
                        Stepper("Number of Questions: \(numberOfQuestionStepper)", value: $numberOfQuestionStepper, in: 5...20)
                            .padding()
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(9)
                    
                    HStack {
                        Text(leftNumber, format: .number)
                            .opacityAnimation(state: isAnimating, delay: delay, opacity: opacity)
                        Text("x")
                            .opacityAnimation(state: isAnimating, delay: delay + 1, opacity: opacity)
                        Text(rightNumber, format: .number)
                            .opacityAnimation(state: isAnimating, delay: delay + 1.5, opacity: opacity)
                        Text("=")
                            .opacityAnimation(state: isAnimating, delay: delay + 2, opacity: opacity)
                        TextField("Result", text: $result, prompt: Text("?").foregroundColor(.white))
                            .underline(color: isGoodAnswer ? .green : .red)
                            .frame(maxWidth: 100)
                            .keyboardType(.numberPad)
                            .focused($isFocusedResultTextField)
                            .opacityAnimation(state: isAnimating, delay: delay + 2.5, opacity: opacity)
                    }
                    .font(.largeTitle)
                    
                    Button("Verify") {
                        showingAlert = true
                        verify()
                        isDisabledButton = true
                        opacity = 0
                    }
                    .font(.headline)
                    .frame(width: 200, height: 80)
                    .background(isDisabledButton ? .gray : .mint)
                    .cornerRadius(12)
                    .disabled(isDisabledButton)
                    
                    Text("Score: \(score)")
                        .font(.largeTitle)
                }
                .padding()
                .foregroundColor(.white)
                .alert(titleAlert, isPresented: $showingAlert) {
                    Button("OK") {
                        isAnimating = false
                        
                        withAnimation() {
                            isEndGame ? endGame() : startGame()
                            result = ""
                        }
                    }
                    
                } message: {
                    Text(messageAlert)
                }
                .alert(titleAlert, isPresented: $showingEnfGameAlert) {
                    Button("Restart") {
                        isAnimating = false
                        withAnimation(.easeInOut(duration: 1).delay(0.5)) {
                            reset(currentScore: 0)
                            startGame()
                        }
                    }
                    
                    Button("Continue") {
                        isAnimating = false
                        withAnimation(.easeInOut(duration: 1).delay(0.5)) {
                            startGame()
                            reset(currentScore: score)
                        }
                    }
                }
                .onAppear {
                    startGame()
//                    isAnimating.toggle()
                    animationDegree += 360
                }
            } //: ZSTACK
            .navigationTitle("Edutainment")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isFocusedResultTextField.toggle()
                    } label: {
                        Text("Done")
                    }
                }
            }
        } //: NAVIGATION
    } //: BODY
    
    //MARK: - FUNCTIONS
    
    func startGame() {
        isAnimating = true
        currentGameNumber += 1
        let range = Array(2...12)
        if let number = range.randomElement() {
            leftNumber = number
        }
        if let number = range.randomElement() {
            rightNumber = number
        }
        opacity = 1
        withAnimation(.easeInOut(duration: 1).delay(delay + 3)) {
            isDisabledButton = false
        }
    }
    
    func verify() {
        result = result.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if isGoodAnswer {
            titleAlert = "Good"
            messageAlert = "\(leftNumber) x \(rightNumber) = \(leftNumber * rightNumber)"
            score += 1
        } else {
            titleAlert = "Bad answer"
            messageAlert = "The right answer is \(leftNumber * rightNumber)"
        }
    }
    
    func endGame() {
        showingAlert = false
        showingEnfGameAlert = true
        titleAlert = "End Game"
        messageAlert = "Your final score is \(score)"
    }
    
    func reset(currentScore: Int) {
        score = currentScore
        result = ""
        currentGameNumber = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
