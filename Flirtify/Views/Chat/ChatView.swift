import Observation
import SwiftUI

struct ChatView: View {
    let viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .background(Color(.secondarySystemBackground))
                .onAppear {
                    scrollToBottom(using: proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(using: proxy)
                }
            }

            composer
                .padding()
                .background(Color.black.opacity(0.25))
        }
        .navigationTitle(viewModel.otherUser.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadMessages()
        }
    }

    private var composer: some View {
        @Bindable var bindableViewModel = viewModel

        return HStack(spacing: 10) {
            TextField(
                "",
                text: $bindableViewModel.draftMessage,
                prompt: Text("Ecris un message...").foregroundStyle(Color.white.opacity(0.55)),
                axis: .vertical
            )
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
                .tint(.white)

            Button(action: viewModel.sendDraftMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(viewModel.canSendDraft ? Color.blue : Color.white.opacity(0.3))
                    .clipShape(Circle())
            }
            .disabled(!viewModel.canSendDraft)
        }
    }

    private func messageBubble(_ message: Message) -> some View {
        let isCurrentUser = viewModel.isFromCurrentUser(message)

        return HStack {
            if isCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isCurrentUser ? Color.blue : Color.white.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        isCurrentUser ? Color.clear : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )

                Text(Self.timeFormatter.string(from: message.sentAt))
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.58))
            }

            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }

    private func scrollToBottom(using proxy: ScrollViewProxy) {
        guard let lastMessage = viewModel.messages.last else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
