import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

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
                .background(Color(.systemBackground))
        }
        .navigationTitle(viewModel.otherUser.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadMessages()
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Write a message...", text: $viewModel.draftMessage, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            Button(action: viewModel.sendDraftMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(viewModel.canSendDraft ? Color.blue : Color.gray)
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
                    .foregroundStyle(isCurrentUser ? Color.white : Color.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(isCurrentUser ? Color.blue : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(Self.timeFormatter.string(from: message.sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
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
