//
//  UserDefaults+AppGroup.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import Foundation

var talkAIBotUD: UserDefaults { return .discoveryGlobalAppGroup() }

struct UserDefaultsKeys {
    static let openAIApiKey = "openAIApiKey"
    static let chatApiModel = "chatApiModel"
}


extension UserDefaults {
    public class func discoveryGlobalAppGroup() -> UserDefaults {
        return .init(suiteName: "talkAIBot")!
    }
    
    // OpenAPIキー設定
    var openAIApiKey: String? {
        get { return string(forKey: UserDefaultsKeys.openAIApiKey) }
        set { set(newValue, forKey: UserDefaultsKeys.openAIApiKey) }
    }
    
    var chatApiModel: Int {
        get { return integer(forKey: UserDefaultsKeys.chatApiModel) }
        set { set(newValue, forKey: UserDefaultsKeys.chatApiModel) }
    }
}
