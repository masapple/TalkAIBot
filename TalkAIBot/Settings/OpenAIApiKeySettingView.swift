//
//  OpenAIApiKeySetting.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import SwiftUI

struct OpenAIApiKeySettingView: View {
    private let settings: SettingsModel = .shared
    @Binding var tempTextInput: String

    var body: some View {
        Form {
            Section(header: Text("openai-api-key")) {
                SecureInputView("please-enter", text: $tempTextInput)
            }
            
            Button(action: {
                settings.openaiApiKey = tempTextInput
            }) {
                Text("save")
            }
        }
        .navigationBarTitle("openai-api-key-setting")
        .navigationBarTitleDisplayMode(.inline)
    }
}
