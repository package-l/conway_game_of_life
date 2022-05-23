//
//  AddConfigurationView.swift
//  FinalProject
//
//  Created by Van Simmons on 7/25/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Configurations
import Combine

struct AddConfigurationView: View {
    var store: Store<AddConfigState, AddConfigState.Action>
    @ObservedObject var viewStore: ViewStore<AddConfigState, AddConfigState.Action>
    @State private var keyboardHeight: CGFloat = 0
    @State private var myText: String = "Name"

    init(store: Store<AddConfigState, AddConfigState.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack {
                    //Problem 5C Goes inside the following HStacks...
                    HStack {
                        Spacer()
                    }
                    HStack {
                        Text("Title:")
                            .foregroundColor(Color.gray)
                            .padding(.trailing, 8.0)
                            .frame(width: proxy.size.width * 0.2, alignment: .trailing)
                        Spacer()
                        TextField(
                            "Title",
                            text: $myText
                        )
                        .font(.title)
                        .disableAutocorrection(true)
                        .background(Color.white)
                        .foregroundColor(Color("accent"))
                        .multilineTextAlignment(.center)
                    }

                    HStack {
                        Text("Size:")
                            .foregroundColor(Color.gray)
                            .padding(.trailing, 8.0)
                            .frame(width: proxy.size.width * 0.2, alignment: .trailing)
                        Spacer()
                        CounterView(
                            store: self.store.scope(
                                state: \.counterState,
                                action: AddConfigState.Action.counterStateAction(action: )
                            )
                        )
                        .font(.title)
                        .disableAutocorrection(true)
                        .background(Color.white)
                        .foregroundColor(Color("accent"))
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 30.0)
                    }
                }
                .padding()
                .overlay(Rectangle().stroke(Color.gray, lineWidth: 2.0))
                .padding(.bottom, 24.0)
                
                HStack {
                    Spacer()
                }

                HStack {
                    Spacer()
                    // Problem 5D - your answer goes in the following buttons
                    ThemedButton(text: "Save") {
                        viewStore.send(.updateTitle(myText))
                        viewStore.send(.ok)
                    }
                    ThemedButton(text: "Cancel") {
                        viewStore.send(.cancel)
                    }
                }
                // Problem 5E - Your answer goes here.
                .padding(.bottom, self.keyboardHeight)
                .onReceive(Publishers.keyboardHeight) {
                    self.keyboardHeight = $0
                }
                .animation(.default)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .frame(width: proxy.size.width * 0.75)
            .padding([.leading, .trailing], 60.0)
            .padding(.top, 100.0)
        }
    }
}

struct AddConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        AddConfigurationView(
            store: Store<AddConfigState, AddConfigState.Action>(
                initialState: AddConfigState(
                    title: "",
                    counterState: CounterState(count: 10)
                ),
                reducer: addConfigReducer,
                environment: AddConfigEnvironment()
            )
        )
    }
}
