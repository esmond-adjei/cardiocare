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
          'Engaging in regular physical activity is one of the best things you can do for your health. Not only does it improve cardiovascular health, but it also boosts mood and energy levels, helping you feel more vibrant and lively throughout the day. Daily exercise aids in weight management, ensuring you maintain a healthy body weight, which in turn reduces the risk of chronic diseases such as diabetes and heart disease.\n\nExercise also has remarkable benefits for mental health. It can help alleviate symptoms of depression and anxiety, promoting a sense of well-being and happiness. Additionally, staying active helps improve sleep quality, ensuring you wake up feeling refreshed and ready to tackle the day. Whether it\'s a brisk walk, a session at the gym, or a yoga class, incorporating some form of physical activity into your daily routine can lead to a healthier, happier you.',
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
          'A balanced diet is the cornerstone of good health. It ensures that your body gets all the essential nutrients it needs to function correctly. By consuming a variety of foods from all food groups, you can maintain energy levels, support bodily functions, and reduce the risk of chronic illnesses.\n\nEating a balanced diet provides the necessary vitamins, minerals, and fiber that your body needs to stay healthy and strong. It helps regulate body weight by preventing excess weight gain and reducing the risk of obesity-related conditions such as type 2 diabetes and heart disease. Moreover, a balanced diet supports brain health, enhancing cognitive function and reducing the risk of mental health disorders.\n\nIncorporating fruits, vegetables, whole grains, lean proteins, and healthy fats into your daily meals can make a significant difference in your overall well-being. By making mindful food choices and avoiding processed foods high in sugar and unhealthy fats, you can enjoy a healthier, more vibrant life.',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/healthy-food-clean-eating-selection-diet-concept_1220-1393.jpg',
      keyTakeaways: [
        'Provides essential nutrients',
        'Helps maintain a healthy weight',
        'Reduces the risk of chronic diseases'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'The importance of a balanced diet',
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
          'Quality sleep is essential for maintaining overall health and well-being. It allows your body to repair itself and your brain to consolidate memories and process information. Without adequate sleep, your cognitive functions can suffer, leading to decreased productivity and an increased risk of mental health issues.\n\nTo improve your sleep quality, establish a consistent bedtime routine. Going to bed and waking up at the same time every day helps regulate your body\'s internal clock. Creating a comfortable sleep environment is also crucial. Ensure your bedroom is dark, quiet, and cool, and invest in a good quality mattress and pillows.\n\nLimiting screen time before bed is another effective strategy. The blue light emitted by phones, tablets, and computers can interfere with the production of melatonin, the hormone responsible for regulating sleep. Try reading a book or practicing relaxation techniques instead. By following these tips, you can enhance your sleep quality and wake up feeling refreshed and ready to face the day.',
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
  BlogPost(
      id: '4',
      title: 'The power of mindfulness',
      subtitle: 'Enhance your well-being with mindfulness practices',
      description:
          'Mindfulness practices can improve mental clarity, reduce stress, and enhance overall well-being.',
      authorName: 'Emily Brown',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 15)),
      content:
          'Mindfulness is the practice of being present and fully engaged with whatever we are doing at the moment. It helps us become more aware of our thoughts, feelings, and surroundings, leading to a more balanced and peaceful life. By incorporating mindfulness into your daily routine, you can reduce stress, improve mental clarity, and enhance your overall well-being.\n\nOne of the key benefits of mindfulness is its ability to reduce stress and anxiety. When we focus on the present moment, we are less likely to get caught up in worries about the past or future. This can help us feel more grounded and calm. Additionally, mindfulness practices such as meditation can improve concentration and focus, making it easier to handle daily tasks and challenges.\n\nTo start practicing mindfulness, set aside a few minutes each day to sit quietly and focus on your breath. Pay attention to the sensations in your body and the sounds around you. As you become more comfortable with mindfulness, you can incorporate it into other activities, such as walking, eating, or even doing household chores. By making mindfulness a part of your life, you can experience greater peace, clarity, and joy.',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/relaxed-fit-woman-tracksuit-sits-lotus-pose-karemat-breathes-deeply-practices-yoga-tries-meditates-outdoors-poses-against-modern-city-building-healthy-living-relaxation-concept_273609-59146.jpg',
      keyTakeaways: [
        'Reduces stress and anxiety',
        'Improves concentration and focus',
        'Enhances overall well-being'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'The power of mindfulness',
          url: 'https://www.mindful.org/what-is-mindfulness/',
        ),
        RelatedArticle(
          title: 'The power of mindfulness',
          url: 'https://www.mindful.org/what-is-mindfulness/',
        ),
        RelatedArticle(
          title: 'The power of mindfulness',
          url: 'https://www.mindful.org/what-is-mindfulness/',
        ),
      ]),
  BlogPost(
      id: '5',
      title: 'Staying hydrated: Why it matters',
      subtitle: 'The importance of drinking enough water',
      description:
          'Staying hydrated is essential for maintaining good health and overall well-being.',
      authorName: 'Michael Johnson',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 20)),
      content:
          'Water is crucial for our bodies to function properly. It helps regulate body temperature, transport nutrients, and remove waste. Despite its importance, many people do not drink enough water daily. Staying hydrated is vital for maintaining good health and overall well-being.\n\nDrinking enough water helps keep your skin healthy and glowing, supports digestion, and prevents constipation. It also aids in maintaining a healthy weight, as sometimes thirst is mistaken for hunger, leading to overeating. Proper hydration can also improve physical performance, as even mild dehydration can impair physical performance and lead to fatigue.\n\nTo ensure you are drinking enough water, aim to drink at least eight 8-ounce glasses of water a day, also known as the 8x8 rule. However, individual water needs can vary based on factors such as age, activity level, and climate. Carrying a water bottle with you and sipping water throughout the day can help you stay hydrated. Remember, other beverages and foods with high water content, such as fruits and vegetables, can also contribute to your daily water intake.',
      featuredImageUrl:
          'https://img.freepik.com/free-photo/person-drinking-water-after-workout_23-2147795263.jpg',
      keyTakeaways: [
        'Regulates body temperature',
        'Supports digestion and prevents constipation',
        'Improves physical performance'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'Staying hydrated: Why it matters',
          url:
              'https://www.healthline.com/nutrition/how-much-water-should-you-drink-per-day',
        ),
        RelatedArticle(
          title: 'Staying hydrated: Why it matters',
          url:
              'https://www.healthline.com/nutrition/how-much-water-should-you-drink-per-day',
        ),
        RelatedArticle(
          title: 'Staying hydrated: Why it matters',
          url:
              'https://www.healthline.com/nutrition/how-much-water-should-you-drink-per-day',
        ),
      ]),
  BlogPost(
      id: '6',
      title: 'The benefits of outdoor activities',
      subtitle: 'Why spending time outdoors is good for you',
      description:
          'Spending time outdoors has numerous health benefits and can improve your mood and well-being.',
      authorName: 'Sarah Lee',
      authorImageUrl:
          'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp',
      publishDate: DateTime.now().subtract(const Duration(days: 25)),
      content:
          "Spending time outdoors offers numerous health benefits that can improve your physical and mental well-being. Fresh air and natural light can boost your mood and energy levels, making you feel more refreshed and revitalized. Outdoor activities such as hiking, biking, or simply walking in the park can provide a great workout, helping to improve your cardiovascular health and strengthen your muscles.\n\nBeing in nature can also reduce stress and anxiety. The calming effect of nature can help lower cortisol levels, which are often elevated during stressful situations. Additionally, spending time outdoors can enhance your creativity and problem-solving skills. The change of scenery and exposure to natural environments can stimulate your mind and help you think more clearly.\n\nTo make the most of your time outdoors, try to incorporate it into your daily routine. Whether it's a morning walk, a weekend hike, or a picnic in the park, spending time outside can have a positive impact on your health and well-being. Remember to stay safe by wearing sunscreen, staying hydrated, and being mindful of your surroundings.",
      featuredImageUrl:
          'https://img.freepik.com/free-photo/hiker-walking-forest-path_23-2147857753.jpg',
      keyTakeaways: [
        'Boosts mood and energy levels',
        'Reduces stress and anxiety',
        'Improves cardiovascular health'
      ],
      relatedArticles: [
        RelatedArticle(
          title: 'The benefits of outdoor activities',
          url:
              'https://www.healthline.com/health/health-benefits-of-being-outdoors',
        ),
        RelatedArticle(
          title: 'The benefits of outdoor activities',
          url:
              'https://www.healthline.com/health/health-benefits-of-being-outdoors',
        ),
        RelatedArticle(
          title: 'The benefits of outdoor activities',
          url:
              'https://www.healthline.com/health/health-benefits-of-being-outdoors',
        ),
      ]),
];

List<BlogPost> fetchBlogPosts() {
  return blogData;
}
