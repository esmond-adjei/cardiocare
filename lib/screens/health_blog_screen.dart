import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:xmonapp/screens/drawers/blog_detail_screen.dart';
import 'package:xmonapp/services/blog_model.dart';

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

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  static const String backgroundImage =
      'https://img.freepik.com/free-photo/people-working-out-indoors-together-with-dumbbells_23-2149175410.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 10.0,
                  ),
                  child: Text(
                    'Learn about keeping your heart healthy!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    viewportFraction: 0.9,
                  ),
                  items: blogData.take(5).map((post) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BlogDetail(post: post)),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(post.featuredImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 10.0,
                  ),
                  child: Text(
                    'Available Articiles!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) =>
                  _buildBlogCard(context, blogData[index]),
              childCount: blogData.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cardiobot',
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: Colors.red,
        child: const FaIcon(FontAwesomeIcons.userDoctor),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetail(post: post)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.featuredImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.share, color: Colors.red),
              //   onPressed: () {
              //     // Implement sharing functionality
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
