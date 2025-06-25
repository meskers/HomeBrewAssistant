import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingMainApp = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BrewTheme").opacity(0.1),
                    Color("HopGreen").opacity(0.1),
                    Color("MaltGold").opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("onboarding.skip".localized) {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                }
                
                // Main content
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    OnboardingPageView(
                        image: "flask.fill",
                        title: "onboarding.page1.title".localized,
                        subtitle: "onboarding.page1.subtitle".localized,
                        description: "onboarding.page1.description".localized,
                        features: [
                            OnboardingFeature(icon: "book.fill", title: "onboarding.page1.feature1.title".localized, description: "onboarding.page1.feature1.description".localized),
                            OnboardingFeature(icon: "function", title: "onboarding.page1.feature2.title".localized, description: "onboarding.page1.feature2.description".localized),
                            OnboardingFeature(icon: "chart.bar.fill", title: "onboarding.page1.feature3.title".localized, description: "onboarding.page1.feature3.description".localized)
                        ]
                    )
                    .tag(0)
                    
                    // Page 2: Recipe Collection
                    OnboardingPageView(
                        image: "trophy.fill",
                        title: "onboarding.page2.title".localized,
                        subtitle: "onboarding.page2.subtitle".localized,
                        description: "onboarding.page2.description".localized,
                        features: [
                            OnboardingFeature(icon: "graduationcap.fill", title: "onboarding.page2.feature1.title".localized, description: "onboarding.page2.feature1.description".localized),
                            OnboardingFeature(icon: "flag.fill", title: "onboarding.page2.feature2.title".localized, description: "onboarding.page2.feature2.description".localized),
                            OnboardingFeature(icon: "globe", title: "onboarding.page2.feature3.title".localized, description: "onboarding.page2.feature3.description".localized)
                        ]
                    )
                    .tag(1)
                    
                    // Page 3: Professional Tools
                    OnboardingPageView(
                        image: "wrench.and.screwdriver.fill",
                        title: "onboarding.page3.title".localized,
                        subtitle: "onboarding.page3.subtitle".localized,
                        description: "onboarding.page3.description".localized,
                        features: [
                            OnboardingFeature(icon: "percent", title: "onboarding.page3.feature1.title".localized, description: "onboarding.page3.feature1.description".localized),
                            OnboardingFeature(icon: "drop.fill", title: "onboarding.page3.feature2.title".localized, description: "onboarding.page3.feature2.description".localized),
                            OnboardingFeature(icon: "timer", title: "onboarding.page3.feature3.title".localized, description: "onboarding.page3.feature3.description".localized)
                        ]
                    )
                    .tag(2)
                    
                    // Page 4: Community
                    OnboardingPageView(
                        image: "person.3.fill",
                        title: "onboarding.page4.title".localized,
                        subtitle: "onboarding.page4.subtitle".localized,
                        description: "onboarding.page4.description".localized,
                        features: [
                            OnboardingFeature(icon: "camera.fill", title: "onboarding.page4.feature1.title".localized, description: "onboarding.page4.feature1.description".localized),
                            OnboardingFeature(icon: "star.fill", title: "onboarding.page4.feature2.title".localized, description: "onboarding.page4.feature2.description".localized),
                            OnboardingFeature(icon: "square.and.arrow.up", title: "onboarding.page4.feature3.title".localized, description: "onboarding.page4.feature3.description".localized)
                        ]
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicators and navigation
                VStack(spacing: 30) {
                    // Custom page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color("BrewTheme") : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("onboarding.previous".localized) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage -= 1
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if currentPage < totalPages - 1 {
                            Button("onboarding.next".localized) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            }
                            .font(.headline)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color("BrewTheme"))
                            .cornerRadius(25)
                        } else {
                            Button("onboarding.get.started".localized) {
                                completeOnboarding()
                            }
                            .font(.headline)
                            .font(.body.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("BrewTheme"), Color("HopGreen")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color("BrewTheme").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            MainTabView()
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Install default recipes for new users (App Store ready)
        let context = PersistenceController.shared.backgroundContext
        context.perform {
            DefaultRecipeInstaller.installDefaultRecipesToCoreData(context: context)
        }
        
        showingMainApp = true
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let subtitle: String
    let description: String
    let features: [OnboardingFeature]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 20)
                
                // Hero image/icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BrewTheme").opacity(0.2),
                                    Color("HopGreen").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: image)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(Color("BrewTheme"))
                }
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text(title)
                        .font(.largeTitle)
                        .font(.body.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.title3)
                        .font(.body.weight(.medium))
                        .foregroundColor(Color("BrewTheme"))
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Features list
                VStack(spacing: 20) {
                    ForEach(features) { feature in
                        OnboardingFeatureRow(feature: feature)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 50)
            }
        }
    }
}

struct OnboardingFeatureRow: View {
    let feature: OnboardingFeature
    
    var body: some View {
        HStack(spacing: 15) {
            // Feature icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("BrewTheme").opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: feature.icon)
                    .font(.title3)
                    .foregroundColor(Color("BrewTheme"))
            }
            
            // Feature content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct OnboardingFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Launch View with Onboarding Check

struct LaunchView: View {
    @State private var showingOnboarding = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                SplashScreenView()
            } else if showingOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            showingOnboarding = !hasCompletedOnboarding
            isLoading = false
        }
    }
}

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoRotation: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var showingDots = false
    @State private var dotAnimations: [Bool] = [false, false, false]
    @State private var backgroundGradientPhase: Double = 0
    
    var body: some View {
        ZStack {
            // Premium animated background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.brewTheme.opacity(0.15),
                    Color.maltGold.opacity(0.10),
                    Color.hopGreen.opacity(0.05),
                    Color.brewTheme.opacity(0.20)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(backgroundGradientPhase))
            .animation(
                Animation.linear(duration: 8.0)
                    .repeatForever(autoreverses: false),
                value: backgroundGradientPhase
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Premium logo with glow effect
                VStack(spacing: 20) {
                    // Logo container with glow
                    ZStack {
                        // Glow effect layers
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.brewTheme.opacity(glowIntensity * 0.6),
                                        Color.maltGold.opacity(glowIntensity * 0.4),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .blur(radius: 20)
                        
                        // Beer Brewing Logo with premium styling
                        ZStack {
                            // Subtle background glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                            
                            // Main logo image
                            Image("BeerBrewingLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(logoRotation))
                    }
                    
                    // App name with elegant typography
                    VStack(spacing: 8) {
                        Text("splash.app.title".localized)
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.brewTheme,
                                        Color.maltGold
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(textOpacity)
                        
                        Text("splash.app.subtitle".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .opacity(textOpacity * 0.8)
                            
                    }
                }
                
                Spacer()
                
                // Premium loading animation
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.brewTheme,
                                            Color.maltGold
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .scaleEffect(dotAnimations[index] ? 1.3 : 0.6)
                                .opacity(dotAnimations[index] ? 1.0 : 0.4)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: dotAnimations[index]
                                )
                        }
                    }
                    .opacity(showingDots ? 1 : 0)
                    
                    Text("splash.app.tagline".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(showingDots ? 0.7 : 0)
                        
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Background gradient rotation
        withAnimation {
            backgroundGradientPhase = 360
        }
        
        // Logo scale and glow sequence
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            logoScale = 1.0
            glowIntensity = 1.0
        }
        
        // Logo rotation effect
        withAnimation(.easeInOut(duration: 2.0).delay(0.8)) {
            logoRotation = 360
        }
        
        // Text fade in with stagger
        withAnimation(.easeOut(duration: 0.8).delay(1.2)) {
            textOpacity = 1.0
        }
        
        // Loading dots sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showingDots = true
            }
            
            // Animate dots individually
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    dotAnimations[i] = true
                }
            }
        }
        
        // Reset glow for pulsing effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowIntensity = 0.3
            }
        }
    }
}

#Preview {
    OnboardingView()
} 