import SwiftUI

// MARK: - Premium Animation Extensions
extension Animation {
    /// Smooth and professional button press animation
    static var premiumTap: Animation {
        .easeInOut(duration: 0.2)
    }
    
    /// Gentle bounce animation for success states
    static var successBounce: Animation {
        .interpolatingSpring(stiffness: 200, damping: 10)
    }
    
    /// Smooth slide animation for sheet presentations
    static var premiumSlide: Animation {
        .timingCurve(0.25, 0.1, 0.25, 1, duration: 0.5)
    }
    
    /// Dramatic wobble animation for error states
    static var errorWobble: Animation {
        .easeInOut(duration: 0.15).repeatCount(4, autoreverses: true)
    }
    
    /// Premium loading animation
    static var loadingPulse: Animation {
        .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
    }
    
    /// High-end card flip animation
    static var cardFlip: Animation {
        .timingCurve(0.6, 0, 0.4, 1, duration: 1.0)
    }
    
    /// Smooth page transition animation
    static var pageTransition: Animation {
        .timingCurve(0.4, 0, 0.2, 1, duration: 0.6)
    }
    
    /// Elegant floating animation
    static var elegantFloat: Animation {
        .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    }
    
    /// Quick snap animation for immediate feedback
    static var quickSnap: Animation {
        .interpolatingSpring(stiffness: 300, damping: 15)
    }
    
    /// Smooth reveal animation for content
    static var smoothReveal: Animation {
        .timingCurve(0.23, 1, 0.32, 1, duration: 0.4)
    }
    
    /// Premium progress animation
    static var premiumProgress: Animation {
        .timingCurve(0.4, 0, 0.6, 1, duration: 0.8)
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
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .rotationEffect(isPressed ? .degrees(2) : .degrees(0))
            .brightness(isPressed ? 0.2 : 0.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            print("🎯 HAPTIC TRIGGERED: \(hapticStyle)")
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
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
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
            .onChange(of: trigger) { _ in
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
            .onChange(of: isActive) { active in
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
            .onChange(of: isActive) { active in
                glowIntensity = active ? 0.8 : 0
            }
    }
}

// MARK: - Advanced Premium View Modifiers
struct PremiumPageTransition: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.smoothReveal.delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct PremiumLoadingSpinner: ViewModifier {
    @State private var isRotating = false
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(isActive ? .loadingPulse : .easeInOut(duration: 0.3), value: isRotating)
            .onAppear {
                if isActive {
                    isRotating = true
                }
            }
            .onChange(of: isActive) { active in
                isRotating = active
            }
    }
}

struct PremiumProgressBar: ViewModifier {
    let progress: Double
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(height: 4)
                        .overlay(
                            Rectangle()
                                .fill(color)
                                .frame(width: geometry.size.width * progress, height: 4)
                                .animation(.premiumProgress, value: progress),
                            alignment: .leading
                        )
                }
                .frame(height: 4),
                alignment: .bottom
            )
    }
}

struct FloatingActionStyle: ViewModifier {
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isFloating ? 1.05 : 1.0)
            .animation(.elegantFloat, value: isFloating)
            .onAppear {
                isFloating = true
            }
    }
}

struct SuccessCheckmark: ViewModifier {
    @State private var isVisible = false
    @State private var checkmarkScale: CGFloat = 0
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isVisible {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                            .scaleEffect(checkmarkScale)
                            .animation(.successBounce, value: checkmarkScale)
                    }
                }
            )
            .onChange(of: trigger) { shouldShow in
                if shouldShow {
                    withAnimation(.quickSnap) {
                        isVisible = true
                        checkmarkScale = 1.0
                    }
                    
                    // Hide after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.premiumSlide) {
                            isVisible = false
                            checkmarkScale = 0
                        }
                    }
                }
            }
    }
}

struct PremiumShimmer: ViewModifier {
    @State private var shimmerOffset: CGFloat = -200
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: shimmerOffset)
                .animation(isActive ? .loadingPulse : .easeInOut(duration: 0.3), value: shimmerOffset)
                .opacity(isActive ? 1 : 0)
            )
            .clipped()
            .onAppear {
                if isActive {
                    shimmerOffset = 200
                }
            }
            .onChange(of: isActive) { active in
                shimmerOffset = active ? 200 : -200
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
    
    /// Premium page transition animation
    func premiumPageTransition(delay: Double = 0) -> some View {
        modifier(PremiumPageTransition(delay: delay))
    }
    
    /// Premium loading spinner animation
    func premiumLoadingSpinner(isActive: Bool) -> some View {
        modifier(PremiumLoadingSpinner(isActive: isActive))
    }
    
    /// Premium progress bar overlay
    func premiumProgressBar(progress: Double, color: Color = .brewTheme) -> some View {
        modifier(PremiumProgressBar(progress: progress, color: color))
    }
    
    /// Floating action button style
    func floatingAction() -> some View {
        modifier(FloatingActionStyle())
    }
    
    /// Success checkmark animation
    func successCheckmark(trigger: Bool) -> some View {
        modifier(SuccessCheckmark(trigger: trigger))
    }
    
    /// Premium shimmer loading effect
    func premiumShimmer(isActive: Bool) -> some View {
        modifier(PremiumShimmer(isActive: isActive))
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
    
    /// Enhanced button tap with premium haptics
    func premiumTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            // Premium haptic feedback
            switch style {
            case .light:
                HapticManager.shared.lightTap()
            case .medium:
                HapticManager.shared.mediumTap()
            case .heavy:
                HapticManager.shared.heavyTap()
            default:
                HapticManager.shared.mediumTap()
            }
            
            // Premium animation feedback
            withAnimation(.premiumTap) {
                action()
            }
        }
    }
    
    /// Adds comprehensive accessibility for button-like elements
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Tik om te activeren")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility for informational elements
    func accessibleInfo(label: String, value: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(value != nil ? "\(label): \(value!)" : label)
    }
    
    /// Hides decorative elements from accessibility
    func accessibleDecorative() -> some View {
        self.accessibilityHidden(true)
    }
    
    /// Adds accessibility for input fields
    func accessibleInput(label: String, hint: String, value: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityValue(value ?? "")
    }
    
    /// Adds accessibility for navigation elements
    func accessibleNavigation(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint("Navigeer naar \(label)")
            .accessibilityAddTraits(.isButton)
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

// MARK: - 5-Star Voice Over Support
struct AccessibilityHelper {
    /// Announces important app state changes
    static func announce(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    /// Announces layout changes
    static func announceLayoutChange() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
    
    /// Announces screen changes
    static func announceScreenChange() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
} 