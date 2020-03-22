//
//  ContentView.swift
//  WordScramble
//
//  Created by keiren on 3/21/20.
//  Copyright © 2020 keiren. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
       
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Score: \(score)")
                    .font(.title)
                    .fontWeight(.black)
            }
           
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading:
                Button(action: startGame){
                    Text("OTHER WORD")
                        .fontWeight(.bold)
                        .font(.headline)
                }
            )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    /*
     we want to call addNetwork() when the user presses return on the keyboard, and
     in SwiftUI we can do that providing an on commit closure for the textField.
     */
    func addNewWord(){
        /* lowercase an trim the word, to make sure we don't add duplicate words with
        the case differences */
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
       // validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original 😅")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know 🤯")
            return
        }
        
        guard isEqual(word: answer) else {
            wordError(title: "Word is equal to start word", message: "You can't do that ❌")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word 😩")
            return
        }
        /* by inserting words at the start of the array they automatically slide in at the top of the list */
        usedWords.insert(answer, at: 0)
        newWord = ""
        score = score + 1
    }
    
    func startGame(){
        // Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.text into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                // Pick one random word, or use "skilkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem - trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    // already have a usedWords array, so we can pass the word into its contains() method
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if word.count < 3 {
            return false
        }
        return misspelledRange.location == NSNotFound
    }
    
    func isEqual(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
