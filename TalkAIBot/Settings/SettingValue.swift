//
//  SettingValue.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import Foundation
import OpenAI

enum SettingType: Int, CaseIterable {
    case openAIApiKeySettingValue
    case chatApiModelSettingValue
}

class SettingValue<T: Equatable> {
    let type: SettingType
    private(set) var value: T
    var closureForSet: (T) -> Void = { _ in return }
    
    init(type: SettingType, value: T) {
        self.type = type
        self.value = value
    }
    
    func set(_ value: T) {
        if self.value != value {
            closureForSet(value)
            self.value = value
        }
    }
}

class OpenAIApiKeySetting: SettingValue<String> {
    init() {
        super.init(
            type: .openAIApiKeySettingValue,
            value: talkAIBotUD.openAIApiKey ?? ""
        )
        closureForSet = { value in talkAIBotUD.openAIApiKey = value }
    }
}

enum ChatApiModelSettingValue: Int, Identifiable, CaseIterable {
    case gpt4 = 0
    case gpt4_o = 1
    case gpt4_turbo = 2
    case gpt3_5Turbo = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .gpt4:
            return "gpt4"
        case .gpt4_o:
            return "gpt4_o"
        case .gpt4_turbo:
            return "gpt4_turbo"
        case .gpt3_5Turbo:
            return "gpt3_5Turbo"

        }
    }
    
    var convert: Model {
        switch self {
        case .gpt4:
            return .gpt4
        case .gpt4_o:
            return .gpt4_o
        case .gpt4_turbo:
            return .gpt4_turbo
        case .gpt3_5Turbo:
            return .gpt3_5Turbo
        }
    }
}

class ChatApiModelSetting: SettingValue<ChatApiModelSettingValue> {
    init() {
        super.init(
            type: .chatApiModelSettingValue,
            value: ChatApiModelSettingValue(rawValue: talkAIBotUD.chatApiModel) ?? .gpt4_o
        )
        closureForSet = { value in talkAIBotUD.chatApiModel = value.rawValue }
    }
}
