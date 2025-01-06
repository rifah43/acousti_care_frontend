import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:html/parser.dart';

class Article {
  final String title;
  final String description;
  final String url;
  final String publishedAt;
  final String source;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.publishedAt,
    required this.source,
  });
}

class ArticleService {
  // RSS feed URLs from major diabetes organizations
  final Map<String, String> _rssSources = {
    'Diabetes.org': 'https://www.diabetes.org/feed',
    'DiabetesSelfManagement': 'https://www.diabetesselfmanagement.com/feed/',
    'Healthline Diabetes': 'https://www.healthline.com/health/diabetes/feed',
  };

  Future<List<Article>> fetchDiabetesArticles() async {
    try {
      List<Article> allArticles = [];
      
      // Fetch from each RSS feed
      for (var entry in _rssSources.entries) {
        try {
          final articles = await _fetchFromRSS(entry.value, entry.key);
          allArticles.addAll(articles);
        } catch (e) {
          print('Error fetching from ${entry.key}: $e');
          continue;
        }
      }

      // Add static content if RSS feeds didn't provide enough articles
      if (allArticles.length < 5) {
        allArticles.addAll(_getStaticContent());
      }

      // Sort by date
      allArticles.sort((a, b) => 
        DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt))
      );

      return allArticles.take(10).toList();
    } catch (e) {
      print('Error fetching articles: $e');
      return _getStaticContent();
    }
  }

  Future<List<Article>> _fetchFromRSS(String feedUrl, String sourceName) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode != 200) {
        return [];
      }

      final channel = RssFeed.parse(response.body);
      return channel.items?.map((item) => Article(
        title: _cleanText(item.title ?? ''),
        description: _cleanText(item.description ?? 'No description available'),
        url: item.link ?? '',
        publishedAt: item.pubDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        source: sourceName,
      )).toList() ?? [];

    } catch (e) {
      print('RSS parsing error: $e');
      return [];
    }
  }

  String _cleanText(String text) {
    // Parse HTML and extract text content
    final document = parse(text);
    return document.body?.text ?? text;
  }

  List<Article> _getStaticContent() {
    return [
      Article(
        title: 'Understanding Type 2 Diabetes Management',
        description: 'Learn about lifestyle changes, medication, and monitoring for effective diabetes management.',
        url: 'https://www.diabetes.org/diabetes/type-2',
        publishedAt: DateTime.now().toIso8601String(),
        source: 'American Diabetes Association',
      ),
      Article(
        title: 'Diet and Exercise Guidelines for Diabetes',
        description: 'Discover the best practices for maintaining a healthy diet and exercise routine with type 2 diabetes.',
        url: 'https://www.diabetesselfmanagement.com/nutrition-exercise',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        source: 'Diabetes Self-Management',
      ),
      Article(
        title: 'Latest Advances in Diabetes Treatment',
        description: 'Stay informed about the newest developments in type 2 diabetes treatment and research.',
        url: 'https://www.healthline.com/health/type-2-diabetes/treatment-advances',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        source: 'Healthline',
      ),
      Article(
        title: 'Recognizing and Managing Diabetes Complications',
        description: 'Learn to identify and prevent common complications associated with type 2 diabetes.',
        url: 'https://www.diabetes.org/diabetes/complications',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        source: 'American Diabetes Association',
      ),
      Article(
        title: 'Mental Health and Diabetes',
        description: 'Understanding the connection between mental health and diabetes management.',
        url: 'https://www.diabetesselfmanagement.com/mental-health',
        publishedAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        source: 'Diabetes Self-Management',
      ),
    ];
  }
}