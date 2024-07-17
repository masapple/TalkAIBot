//
//  SettingsViewModel.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/16.
//

import Foundation
import Combine

class SettingsModel {
    // シングルトン
    static let shared: SettingsModel = .init()
    
    private let openaiApiKeySetting: OpenAIApiKeySetting = .init()
    var openaiApiKey: String {
        get { openaiApiKeySetting.value }
        set(value) { openaiApiKeySetting.set(value) }
    }
    
    private let chatApiModelSetting: ChatApiModelSetting = .init()
    var chatApiModel: ChatApiModelSettingValue {
        get { chatApiModelSetting.value }
        set(value) { chatApiModelSetting.set(value) }
    }
}
