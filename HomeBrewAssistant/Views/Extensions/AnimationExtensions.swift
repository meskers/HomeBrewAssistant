import SwiftUI

// MARK: - Premium Animation Extensions
extension Animation {
    /// Smooth and professional button press animation
    static var premiumTap: Animation {
        .easeInOut(duration: 0.15)
    }
    
    /// Gentle bounce animation for success states
    static var successBounce: Animation {
        .interpolatingSpring(stiffness: 300, damping: 15)
    }
    
    /// Smooth slide animation for sheet presentations
    static var premiumSlide: Animation {
        .timingCurve(0.25, 0.1, 0.25, 1, duration: 0.35)
    }
    
    /// Subtle wobble animation for error states
    static var errorWobble: Animation {
        .easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)
    }
    
    /// Premium loading animation
    static var loadingPulse: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    }
    
    /// High-end card flip animation
    static var cardFlip: Animation {
        .timingCurve(0.6, 0, 0.4, 1, duration: 0.8)
    }
}

// MARK: - Premium Haptic Feedback Manager
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Light tap feedback for button presses
    func lightTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Medium feedback for selections
    func mediumTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Heavy feedback for important actions
    func heavyTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    /// Success feedback for completed actions
    func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning feedback for attention-needed actions
    func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error feedback for failed actions
    func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Selection feedback for picker changes
    func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - View Modifiers for Premium UX
struct PremiumButtonStyle: ViewModifier {
    @State private var isPressed = false
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    init(hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        self.hapticStyle = hapticStyle
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.premiumTap, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
                if pressing {
                    switch hapticStyle {
                    case .light:
                        HapticManager.shared.lightTap()
                    case .medium:
                        HapticManager.shared.mediumTap()
                    case .heavy:
                        HapticManager.shared.heavyTap()
                    case .rigid:
                        HapticManager.shared.heavyTap()
                    case .soft:
                        HapticManager.shared.lightTap()
                    @unknown default:
                        HapticManager.shared.lightTap()
                    }
                }
            }, perform: {})
    }
}

struct PremiumCardStyle: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(isHovered ? 0.15 : 0.05), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.premiumSlide, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct ShakeEffect: ViewModifier {
    @State private var shakeOffset: CGFloat = 0
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, _ in
                withAnimation(.errorWobble) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shakeOffset = 0
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(isActive ? .loadingPulse : .easeInOut(duration: 0.2), value: isPulsing)
            .onAppear {
                if isActive {
                    isPulsing = true
                }
            }
            .onChange(of: isActive) { _, active in
                isPulsing = active
            }
    }
}

struct GlowEffect: ViewModifier {
    @State private var glowIntensity: Double = 0
    let color: Color
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(glowIntensity), radius: 10, x: 0, y: 0)
            .shadow(color: color.opacity(glowIntensity * 0.6), radius: 20, x: 0, y: 0)
            .animation(.loadingPulse, value: glowIntensity)
            .onAppear {
                if isActive {
                    glowIntensity = 0.8
                }
            }
            .onChange(of: isActive) { _, active in
                glowIntensity = active ? 0.8 : 0
            }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply premium button styling with haptic feedback
    func premiumButton(hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        modifier(PremiumButtonStyle(hapticStyle: hapticStyle))
    }
    
    /// Apply premium card styling with hover effects
    func premiumCard() -> some View {
        modifier(PremiumCardStyle())
    }
    
    /// Add shake animation on error
    func shake(trigger: Bool) -> some View {
        modifier(ShakeEffect(trigger: trigger))
    }
    
    /// Add pulse animation for loading states
    func pulse(isActive: Bool) -> some View {
        modifier(PulseEffect(isActive: isActive))
    }
    
    /// Add glow effect for highlighted states
    func glow(color: Color = .brewTheme, isActive: Bool) -> some View {
        modifier(GlowEffect(color: color, isActive: isActive))
    }
    
    /// Success animation with haptic feedback
    func onSuccess(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            HapticManager.shared.success()
            withAnimation(.successBounce) {
                action()
            }
        }
    }
    
    /// Error animation with haptic feedback
    func onError(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            HapticManager.shared.error()
            withAnimation(.errorWobble) {
                action()
            }
        }
    }
}

// MARK: - Custom Transition Effects
extension AnyTransition {
    /// Premium slide from bottom with scale
    static var premiumSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .scale(scale: 0.8)).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .scale(scale: 0.8)).combined(with: .opacity)
        )
    }
    
    /// Premium fade with scale
    static var premiumFade: AnyTransition {
        .scale(scale: 0.9).combined(with: .opacity)
    }
    
    /// Card flip transition
    static var cardFlip: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: FlipModifier(angle: -90, axis: (x: 0, y: 1, z: 0)),
                identity: FlipModifier(angle: 0, axis: (x: 0, y: 1, z: 0))
            ),
            removal: .modifier(
                active: FlipModifier(angle: 90, axis: (x: 0, y: 1, z: 0)),
                identity: FlipModifier(angle: 0, axis: (x: 0, y: 1, z: 0))
            )
        )
    }
}

// MARK: - Helper View Modifiers
struct FlipModifier: ViewModifier {
    let angle: Double
    let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(degrees: angle),
                axis: axis,
                perspective: 0.5
            )
    }
} 