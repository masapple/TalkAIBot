//
//  SpeechRecognizer.swift
//  SpeechRecognitionApp
//
//  Created by masataka-miyagawa on 2024/07/09.
//

import Foundation
import Speech
import OpenAI

class SpeechViewModel: ObservableObject {
    @Published var userText: String = ""
    @Published var aiResponse: String = ""
    @Published var isRecording: Bool = false
    @Published var speechSynthesizer = AVSpeechSynthesizer()

    private let openai: OpenAIAPIProvider = .init()
    private let settings: SettingsModel = .shared
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var timer: Timer?
    
    init() {
        setupAudioSession()
        requestSpeechAuthorization()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session properties weren't set because of an error.")
        }
    }
    
    /// 音声認識開始
    func startRecording() throws {
        print("startRecording")

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask?.finish()
            recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequestTmp = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequestTmp.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("AudioEngine couldn't start because of an error.")
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequestTmp) { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                Task { @MainActor in
                    self.userText = recognizedText
                    print("Recognized Text: \(recognizedText)")
                }
            }

            if let error = error {
                print("Recognition error: \(error)")
                audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                recognitionRequest = nil
                recognitionTask = nil
                isRecording = false
            }
        }
        
        // 録音開始後5秒間経過後に現状の認識結果を下にAIに推論させる
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            timer?.invalidate()
            stopRecording()
            if !userText.isEmpty {
                Task {
                    // 生成AIでテキスト生成し音声で読み上げる
                    await self.generateAIResponse(for: self.userText)
                }
            }
        }
        print("Start Recording End")
    }
    
    /// 音声認識の停止
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }

    // 生成AIで応答用テキストを生成し、AVSpeechUtteranceで読み上げる
    func generateAIResponse(for text: String) async {
        print("Exec generateAIResponse. text: \(text)")
        defer { isRecording = false }

        do {
            // OpenAIにテキストを送信
            aiResponse = try await openai.sendChat(
                apiKey: settings.openaiApiKey,
                model: settings.chatApiModel,
                text: text
            )
            // レスポンスで受けたテキストを音声合成
            convertTextToSpeech(text: aiResponse)
        } catch {
            await MainActor.run {
                aiResponse = "\(error.localizedDescription)"
            }
        }
    }
    
    func convertTextToSpeech(text: String) {
        // 音声合成で応答を読み上げる
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        //utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
    
    private func requestSpeechAuthorization() {
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { micStatus in
            if micStatus {
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    OperationQueue.main.addOperation {
                        switch authStatus {
                        case .authorized:
                            print("Speech recognition authorized")
                        case .denied, .restricted, .notDetermined:
                            print("Speech recognition not authorized")
                        @unknown default:
                            fatalError("Unknown authorization status")
                        }
                    }
                }
            } else {
                print("Mic not authorized")
            }
        }
        
    }
}
