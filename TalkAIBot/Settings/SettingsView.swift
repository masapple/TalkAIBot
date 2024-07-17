//
//  SettingView.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/16.
//

import SwiftUI

struct SettingsView: View {
    @State var openaiApiKeyTextInput: String = ""
    @State var selectedChatApiModelItem: Int? = nil
    private let settings: SettingsModel = .shared
    
    enum SettingItem: String, Identifiable, CaseIterable {
        case openaiApiKeySetting
        case chatApiModelSetting
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .openaiApiKeySetting:
                return NSLocalizedString("openai-api-key", comment: "")
            case .chatApiModelSetting:
                return NSLocalizedString("chat-api-model-setting", comment: "")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("openai-api-setting") {
                    ForEach(SettingItem.allCases) { item in
                        switch item {
                        case .openaiApiKeySetting:
                            // OpenAI APIキー設定
                            NavigationLink(destination: {
                                OpenAIApiKeySettingView(tempTextInput: $openaiApiKeyTextInput)
                            }, label: {
                                HStack {
                                    Text(item.title)
                                    
                                    Spacer()
                                    
                                    if openaiApiKeyTextInput.isEmpty {
                                        Text("not-set")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("\(openaiApiKeyTextInput.prefix(3))***")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            })
                        case .chatApiModelSetting:
                            // ChatAPIモデル設定
                            NavigationLink(destination: {
                                ChatApiModelSettingView(selectedItem: $selectedChatApiModelItem)
                            }, label: {
                                HStack {
                                    Text(item.title)
                                    
                                    Spacer()
                                    
                                    if let selected = selectedChatApiModelItem {
                                        Text(ChatApiModelSettingValue(rawValue: selected)?.title ?? settings.chatApiModel.title)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            })
                        }
                    }
                }
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                openaiApiKeyTextInput = settings.openaiApiKey
                selectedChatApiModelItem = settings.chatApiModel.rawValue
            }
        }
    }
}

#Preview {
    SettingsView()
}
