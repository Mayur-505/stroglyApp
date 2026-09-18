class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  factory OnboardingItem.fromJson(Map<String, dynamic> json) {
    return OnboardingItem(
      imagePath: json['imagePath']?.toString() ?? 'assets/images/onboarding_1.png',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
