import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:acousti_care_frontend/services/article_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ArticleService _articleService = ArticleService();
  bool _isLoading = false;
  List<Article> _articles = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).activeProfileId;
      if (userId == null) {
        _showErrorMessage('Please ensure you are logged in with an active profile to view articles.');
        return;
      }

      final articles = await _articleService.fetchDiabetesArticles();
      
      if (mounted) {
        setState(() => _articles = articles);
        if (articles.isEmpty) {
          _showSuccessMessage('Articles refreshed. Check back later for new content!');
        } else {
          _showSuccessMessage('Successfully loaded ${articles.length} latest diabetes articles');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Unable to fetch articles. Please check your internet connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _refreshDashboard,
        ),
        ),
      );
  }

  Future<void> _openArticle(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      _showErrorMessage('Unable to open article. Please check your internet connection or try again later.');
    }
  }

  Widget _buildArticleCard(Article article) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _openArticle(article.url),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Source tag with flexible width
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.source,
                        style: boldTextStyle(context, AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title with flexible width
                  Flexible(
                    child: Text(
                      article.title,
                      style: nameTitleStyle(context, AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description with flexible width
                  Flexible(
                    child: Text(
                      article.description,
                      style: normalTextStyle(context, AppColors.textPrimary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Read more button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Read more',
                        style: boldTextStyle(context, AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No articles available',
              style: subtitleStyle(context, AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: primaryButtonStyle(),
              onPressed: _refreshDashboard,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Latest Diabetes News',
                  style: titleStyle(context, AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay informed about Type 2 Diabetes management',
                  style: subtitleStyle(context, AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (_articles.isEmpty)
                  _buildEmptyState()
                else
                  ...List.generate(
                    _articles.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < _articles.length - 1 ? 16.0 : 0),
                      child: _buildArticleCard(_articles[index]),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildDashboardContent(),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}