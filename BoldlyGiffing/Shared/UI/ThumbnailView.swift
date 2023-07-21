//
//  ThumbnailView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


public struct Thumbnails: ReducerProtocol {
    public struct State: Equatable {
        var dataSet: IdentifiedArrayOf<Gif> = []
        var postCount = 0
        var characterTag: CharacterTag = .all
        var offset = 0
        var selectedGif: Gif?
        
    }
    
    public enum Action: Equatable {
        case fetchInfo
        case fetchInfoResponse(TaskResult<InfoResponse>)
        case fetchRandomThumbnails
        case fetchThumbnails(limit: Int, offset: Int)
        case fetchThumbnailsResponse(TaskResult<PostResponse>)
        case gifTapped(Gif)
        case setCharacterTag(CharacterTag)
    }
    
    enum CancelID {
        case fetchThumbnails
    }
    
    @Dependency(\.APIClient) var apiClient
    
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchInfo:
            return .run { send in
                await send(.fetchInfoResponse(TaskResult {
                    try await apiClient.request(route: "info", as: InfoResponse.self)
                }))
            }
        case .fetchInfoResponse(.failure(let error)):
            print(error)
            return .none
            
        case let .fetchInfoResponse(.success(response)):
            state.postCount = response.postCount
            
            return .run { send in
                await send(.fetchRandomThumbnails)
            }
            
        case .fetchRandomThumbnails:
            let postCount = state.postCount - (state.postCount > 21 ? 21 : 0)
#if os(iOS)
            let randomOffset = Int.random(postCount)
#elseif os(macOS)
            let randomOffset = Int.random(in: 0...postCount)
#endif
            let offset = randomOffset < 0 ? 0 : randomOffset
            state.offset = offset
            
            return.run { send in
                await send(.fetchThumbnails(limit: 21, offset: offset))
            }
            
        case let .fetchThumbnails(limit, offset):
            
            var tagPath: String = ""
            if let characterTag = state.characterTag.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                tagPath = characterTag.isEmpty ? characterTag : "&tag=\(characterTag)"
            }
            
            let route = "posts/photo?limit=\(limit)&offset=\(offset)\(tagPath)"
            return .run { send in
                await send(.fetchThumbnailsResponse(TaskResult<PostResponse> {
                    try await apiClient.request(route: route, as: PostResponse.self)
                }))
            }
            
        case .fetchThumbnailsResponse(.failure):
            return .none
            
        case let .fetchThumbnailsResponse(.success(response)):
            var newItems: [Gif] = []
            response.posts.forEach { newItems.append(contentsOf: $0.gifs) }
            
            state.dataSet.append(contentsOf: IdentifiedArrayOf(uniqueElements: newItems))
            state.offset += 21
            return .none
        case let .gifTapped(gif):
            state.selectedGif = gif
            
        case let .setCharacterTag(tag):
            state.characterTag = tag
        }
        return .none
    }
}


struct ThumbnailView: View {
    @Namespace var thumbnailNamespace
    @State private var pressedGif: Gif?
    @GestureState private var longPressActive = false
    @State private var completedHold = false
    
    let store: Store<Thumbnails.State, Thumbnails.Action>
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private func holdGesture(_ gif: Gif) -> some Gesture {
        LongPressGesture(minimumDuration: 0.1, maximumDistance: 10).simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($longPressActive) { currentState, gestureState, transaction in
                gestureState = currentState.first == true
            }
            .onChanged { value in
                print("onchange \(value)")
                completedHold = value.first == true
                withAnimation {
                    pressedGif = longPressActive ? gif : nil
                }
            }
            .onEnded({ value in
                withAnimation(.interactiveSpring()) {
                    print("hold ended, long press \(longPressActive)")
                    completedHold = true
                    withAnimation {
                        pressedGif = nil
                    }
                }
            })
    }
    
    var body: some View {
        WithViewStore(store) { store in
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    LazyVGrid(columns: columns, pinnedViews: .sectionHeaders) {
                        Section {
                            // Intentionally left blank
                        } footer: {
                            CharacterView(character: store.binding(
                                get: \.characterTag,
                                send: { .setCharacterTag($0) }
                            ) )
                                .id("CharacterPicker")
                        }
                        .background {
                            CreatorBar()
                                .offset(y: -115)
                        }
                        Section {
                            ForEach(store.dataSet) { gif in
                                GifView(gif: gif)
                                    .matchedGeometryEffect(id: longPressActive ? gif.id : "", in: thumbnailNamespace, isSource: false)
                                    .zIndex(pressedGif == gif ? 2 : 0)
                                    .onTapGesture {
                                        store.send(.gifTapped(gif))
                                    }
                                    .gesture(holdGesture(gif))
                                    .animation( .interactiveSpring(), value: longPressActive)
                                    .overlay {
                                        if store.selectedGif == gif {
//                                            let text = viewModel.downloadProgress < 100 ? "\(viewModel.downloadProgress)" : "Copied"
//                                            Text(text)
//                                                .foregroundColor(.white)
//                                                .font(.LCARS(size: 22))
//                                                .shadow(radius: 1)
                                        }
                                    }
                                    .onAppear {
                                        if gif == store.dataSet[store.dataSet.count - 6] {
                                            store.send(.fetchThumbnails(limit: 21, offset: store.offset))
                                        }
                                    }
                            }
                        } header: {
                            ResultsHeader()
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo("CharacterPicker")
                                    }
                                }
                                .frame(height: 20)
                                .background(
                                    LinearGradient(
                                        stops: [
                                            Gradient.Stop(color: .clear, location: 0),
                                            Gradient.Stop(color: .black, location: 0.3)
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .frame(height: 30)
                                )
                                .padding(.bottom, 8)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.bottom, 30)
                }
            }
            .modifier(VersionAwareBounce())
            .clipped()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black)
                
            )
            .onAppear {
                store.send(.fetchInfo)
            }
            .overlay {
                GifView(gif: pressedGif ?? Gif.empty, isLarge: true)
                    .opacity( longPressActive ? 1 : 0)
                    .matchedGeometryEffect(id: pressedGif?.id, in: thumbnailNamespace)
                    .animation( .interactiveSpring().delay(0.3), value: longPressActive)
                    .frame(height: 200)
                    .padding(16)
                
            }
        }
    }
}

fileprivate struct VersionAwareBounce: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 13.3, iOS 16.4, *) {
            content.scrollBounceBehavior(.always, axes: .vertical)
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(store:
                .init(
                    initialState: Thumbnails.State.init(),
                    reducer: Thumbnails()
                )
        )
    }
}
