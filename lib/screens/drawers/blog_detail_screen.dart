import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xmonapp/services/blog_model.dart';

class BlogDetail extends StatelessWidget {
  final BlogPost post;

  const BlogDetail({super.key, required this.post});

  static const String placeholderImage =
      'assets/images/blog-image-placeholder.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                post.title,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image.network(post.featuredImageUrl, fit: BoxFit.cover),
                  FadeInImage.assetNetwork(
                    placeholder: placeholderImage,
                    image: post.featuredImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.redAccent, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          post.authorImageUrl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMMM d, yyyy').format(post.publishDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Key Takeaways:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...post.keyTakeaways.map(_buildTakeaway),
                  if (post.relatedArticles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Further Reading:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...post.relatedArticles.map(_buildRelatedArticle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Sharing article...')),
      //     );
      //   },
      //   child: const Icon(Icons.share),
      // ),
    );
  }

  Widget _buildTakeaway(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildRelatedArticle(RelatedArticle article) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.article),
        title: Text(article.title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to related article using article
        },
      ),
    );
  }
}
