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
                    Button("Skip") {
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
                        title: "Welcome to HomeBrewAssistant",
                        subtitle: "Your complete brewing companion",
                        description: "Start your brewing journey with the most comprehensive homebrew assistant app.",
                        features: [
                            OnboardingFeature(icon: "book.fill", title: "50+ Expert Recipes", description: "Award-winning formulas"),
                            OnboardingFeature(icon: "calculator.fill", title: "Professional Tools", description: "ABV, IBU, SRM calculators"),
                            OnboardingFeature(icon: "chart.bar.fill", title: "Analytics", description: "Track your brewing progress")
                        ]
                    )
                    .tag(0)
                    
                    // Page 2: Recipe Collection
                    OnboardingPageView(
                        image: "trophy.fill",
                        title: "Discover Amazing Recipes",
                        subtitle: "Start with our curated collection",
                        description: "Discover our curated collection of award-winning recipes from master brewers worldwide.",
                        features: [
                            OnboardingFeature(icon: "graduationcap.fill", title: "Beginner Friendly", description: "97% success rate recipes"),
                            OnboardingFeature(icon: "flag.fill", title: "Dutch Classics", description: "Authentic local styles"),
                            OnboardingFeature(icon: "globe", title: "World Favorites", description: "International beer styles")
                        ]
                    )
                    .tag(1)
                    
                    // Page 3: Professional Tools
                    OnboardingPageView(
                        image: "wrench.and.screwdriver.fill",
                        title: "Professional Tools",
                        subtitle: "Calculators and tracking tools",
                        description: "Professional-grade calculators and tools to perfect every aspect of your brew.",
                        features: [
                            OnboardingFeature(icon: "percent", title: "ABV Calculator", description: "Precise alcohol content"),
                            OnboardingFeature(icon: "drop.fill", title: "IBU Calculator", description: "Hop bitterness levels"),
                            OnboardingFeature(icon: "timer", title: "Brew Timers", description: "Never miss a step")
                        ]
                    )
                    .tag(2)
                    
                    // Page 4: Community
                    OnboardingPageView(
                        image: "person.3.fill",
                        title: "Join the Community",
                        subtitle: "Share and learn from fellow brewers",
                        description: "Join thousands of brewers sharing knowledge, recipes, and brewing experiences.",
                        features: [
                            OnboardingFeature(icon: "camera.fill", title: "Photo Documentation", description: "Share your brewing process"),
                            OnboardingFeature(icon: "star.fill", title: "Rate Recipes", description: "Help others find great brews"),
                            OnboardingFeature(icon: "square.and.arrow.up", title: "Export & Share", description: "BeerXML compatibility")
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
                            Button("Previous") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage -= 1
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if currentPage < totalPages - 1 {
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color("BrewTheme"))
                            .cornerRadius(25)
                        } else {
                            Button("Get Started") {
                                completeOnboarding()
                            }
                            .font(.headline)
                            .fontWeight(.bold)
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
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.title3)
                        .fontWeight(.medium)
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
                    .fontWeight(.semibold)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            showingOnboarding = !hasCompletedOnboarding
            isLoading = false
        }
    }
}

struct SplashScreenView: View {
    @State private var scale = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BrewTheme"),
                    Color("HopGreen"),
                    Color("MaltGold")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App logo/icon
                Image(systemName: "flask.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("HomeBrewAssistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Your Complete Brewing Companion")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    OnboardingView()
} 