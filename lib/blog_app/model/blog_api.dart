import 'package:cardiocare/blog_app/model/blog_model.dart';

final List<BlogPost> blogData = [
  BlogPost(
      id: '1',
      title: 'Benefits of working out, daily!',
      subtitle: 'Boost your health with regular exercise',
      description:
          'Regular exercise has numerous benefits for your overall health and well-being.',
      authorName: 'Jane Doe',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur...',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/young-happy-sportswoman-getting-ready-workout-tying-shoelace-fitness-center_637285-470.jpg',
      keyTakeaways: [
        'Improves cardiovascular health',
        'Boosts mood and energy levels',
        'Helps maintain a healthy weight'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'Benefits of working out, daily!',
          url: 'https://www.healthline.com/nutrition/10-benefits-of-exercise',
        ),
        RelatedArticle(
          title: 'Benefits of working out, daily!',
          url: 'https://www.healthline.com/nutrition/10-benefits-of-exercise',
        ),
        RelatedArticle(
          title: 'Benefits of working out, daily!',
          url: 'https://www.healthline.com/nutrition/10-benefits-of-exercise',
        ),
      ]),
  BlogPost(
      id: '2',
      title: 'The importance of a balanced diet',
      subtitle: 'Eating right for a healthier you',
      description:
          'A balanced diet is essential for maintaining good health and preventing chronic diseases.',
      authorName: 'John Doe',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/healthy-food-clean-eating-selection-diet-concept_1220-1393.jpg',
      keyTakeaways: [
        'Provides essential nutrients',
        'Helps maintain a healthy weight',
        'Reduces the risk of chronic diseases'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'dexter - new blod',
          url:
              'https://xmondev.pythonanywhere.com/post/dexter-new-blood-hulu-series',
        ),
        RelatedArticle(
          title: 'The importance of a balanced diet',
          url: 'https://www.healthline.com/nutrition/balanced-diet',
        ),
        RelatedArticle(
          title: 'The importance of a balanced diet',
          url: 'https://www.healthline.com/nutrition/balanced-diet',
        ),
      ]),
  BlogPost(
      id: '3',
      title: 'Tips for a good night\'s sleep',
      subtitle: 'Improve your sleep quality with these tips',
      description:
          'Getting enough sleep is crucial for your physical and mental health.',
      authorName: 'Alice Smith',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 10)),
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/people-sleeping_1150-185.jpg',
      keyTakeaways: [
        'Establish a bedtime routine',
        'Create a comfortable sleep environment',
        'Limit screen time before bed'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'Tips for a good night\'s sleep',
          url:
              'https://www.sleepfoundation.org/sleep-hygiene/healthy-sleep-tips',
        ),
        RelatedArticle(
          title: 'Tips for a good night\'s sleep',
          url:
              'https://www.sleepfoundation.org/sleep-hygiene/healthy-sleep-tips',
        ),
        RelatedArticle(
          title: 'Tips for a good night\'s sleep',
          url:
              'https://www.sleepfoundation.org/sleep-hygiene/healthy-sleep-tips',
        ),
      ]),
];

List<BlogPost> fetchBlogPosts() {
  return blogData;
}
