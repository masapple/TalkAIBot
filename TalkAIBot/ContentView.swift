//
//  ContentView.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/01.
//

import SwiftUI

struct ContentView: View {
    private let settings: SettingsModel = .shared
    @StateObject var speechVM: SpeechViewModel = .init()
    @State private var showSettingsView: Bool = false
    @State private var showOpenAIApiKeyAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("user-say")
                        .font(.headline)
                    Text(speechVM.userText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("ai-response")
                        .font(.headline)
                    Text(speechVM.aiResponse)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    guard !settings.openaiApiKey.isEmpty else {
                        showOpenAIApiKeyAlert.toggle()
                        return
                    }
                    
                    if !speechVM.isRecording {
                        // 録音開始
                        try! speechVM.startRecording()
                    } else {
                        // 録音停止
                        speechVM.stopRecording()
                    }
                }) {
                    Image(systemName: "mic")
                      .symbolRenderingMode(speechVM.isRecording ? .palette : .monochrome)
                      .foregroundStyle(speechVM.isRecording ? .pink : .black, .black)
                      .symbolVariant(speechVM.isRecording ? .slash : .none)
                      .symbolVariant(.circle)
                      .font(.system(size: 70))
                }
                .alert(isPresented: $showOpenAIApiKeyAlert, content: {
                    Alert(
                        title: Text("openai-api-key"),
                        message: Text("apikey-not-set"),
                        dismissButton: .default(Text("ok"))
                    )
                })
                
                if speechVM.isRecording {
                    Text("recognizing-voice")
                        .padding()
                } else {
                    Text("push-mic-button-to-speak")
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("talk-ai-bot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsView.toggle() }, label: {
                        Image(systemName: "gearshape.fill")
                    })
                    .sheet(isPresented: $showSettingsView, content: {
                        SettingsView()
                    })
                }
            }
            .onAppear {
                speechVM.convertTextToSpeech(text: NSLocalizedString("welcome-message", comment: ""))
            }
        }
    }
}

#Preview {
    ContentView()
}
