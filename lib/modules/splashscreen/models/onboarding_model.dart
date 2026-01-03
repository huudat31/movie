class OnboardingModel {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

// Onboarding data
final List<OnboardingModel> onboardingPages = [
  OnboardingModel(
    title: 'Unlimited Entertainment',
    description: 'Watch thousands of movies and TV shows on all your devices',
    imageUrl:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
  ),
  OnboardingModel(
    title: 'Download & Watch Offline',
    description:
        'Download your favorite content and watch it anywhere, anytime',
    imageUrl:
        'https://images.unsplash.com/photo-1574267432644-f610f5b45e9c?w=800',
  ),
  OnboardingModel(
    title: 'Create Your Watchlist',
    description: 'Save your favorite movies and series to watch later',
    imageUrl:
        'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
  ),
];
