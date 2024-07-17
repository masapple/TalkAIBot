//
//  PasswordFieldView.swift
//  TalkAIBot
//
//  Created by Masataka Miyagawa on 2024/07/17.
//

import SwiftUI

struct SecureInputView: View {
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        HStack {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text, axis: .vertical)
                }
            }.padding(.trailing, 10)

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }.padding(10)
        }
    }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dummyText: String = "サンプル"
        SecureInputView("APIキー設定", text: $dummyText)
    }
}
