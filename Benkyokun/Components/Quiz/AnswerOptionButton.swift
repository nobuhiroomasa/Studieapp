import SwiftUI

enum AnswerOptionButtonState {
    case normal
    case selected
    case correct
    case incorrect
}

struct AnswerOptionButton: View {
    let option: AnswerOption
    let text: String
    var isSelected = false
    var state: AnswerOptionButtonState = .normal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(option.rawValue)
                    .font(.headline.bold())
                    .frame(width: 38, height: 38)
                    .background(labelBackgroundColor)
                    .foregroundStyle(labelForegroundColor)
                    .clipShape(Circle())

                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 58)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1.4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var resolvedState: AnswerOptionButtonState {
        isSelected && state == .normal ? .selected : state
    }

    private var backgroundColor: Color {
        switch resolvedState {
        case .normal:
            return Color.appCardBackground
        case .selected:
            return Color.appPrimaryLight
        case .correct:
            return Color.appSuccessLight
        case .incorrect:
            return Color.appErrorLight
        }
    }

    private var borderColor: Color {
        switch resolvedState {
        case .normal:
            return Color.gray.opacity(0.18)
        case .selected:
            return Color.appPrimary
        case .correct:
            return Color.appSuccess
        case .incorrect:
            return Color.appError
        }
    }

    private var labelBackgroundColor: Color {
        switch resolvedState {
        case .normal:
            return Color.appPrimaryLight
        case .selected:
            return Color.appPrimary
        case .correct:
            return Color.appSuccess
        case .incorrect:
            return Color.appError
        }
    }

    private var labelForegroundColor: Color {
        resolvedState == .normal ? Color.appPrimary : Color.white
    }
}
