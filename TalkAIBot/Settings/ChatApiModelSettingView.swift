//
//  ChatApiModelSettingView.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import SwiftUI
import OpenAI

struct ChatApiModelSettingView: View {
    @Binding var selectedItem: Int?
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(ChatApiModelSettingValue.allCases) { item in
                HStack {
                    Text(item.title).tag(item.rawValue)
                    if selectedItem == item.rawValue {
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationBarTitle("chat-api-model-setting")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("chatApiModel: \(SettingsModel.shared.chatApiModel)")
            selectedItem = SettingsModel.shared.chatApiModel.rawValue
        }
        .onChange(of: selectedItem) {
            SettingsModel.shared.chatApiModel = ChatApiModelSettingValue(rawValue: selectedItem ?? 0) ?? .gpt4_o
        }
    }
}
