//
//  OpenAIAPIProvider.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import Foundation
import OpenAI

enum OpenAIAPIError: Error {
    case invalidParam, invalidResponse
}

class OpenAIAPIProvider {
    func sendChat(apiKey: String, model: ChatApiModelSettingValue, text: String) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIAPIError.invalidParam }
        let openAI = OpenAI(apiToken: apiKey)

        guard
            let message = ChatQuery.ChatCompletionMessageParam(role: .user, content: text)
        else {
            print("Invalid Param.")
            throw OpenAIAPIError.invalidParam
        }
        let query = ChatQuery(messages: [message], model: model.convert)

        let result = try await openAI.chats(query: query)
        if let firstChoice = result.choices.first {
            switch firstChoice.message {
            case .assistant(let assistantMessage):
                print("openai response: \(assistantMessage.content ?? "No response")")
                return assistantMessage.content ?? "No response"
            default:
                throw OpenAIAPIError.invalidResponse
            }
        } else {
            throw OpenAIAPIError.invalidResponse
        }
    }
}
