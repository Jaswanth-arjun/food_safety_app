import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/rating_provider.dart';
import '../../models/restaurant.dart';
import '../../models/user_review.dart';
import 'report_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import '../../config/constants.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/brand_logo.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, rating, inspection_score
  String _filterBy = 'all'; // all, safe, moderate, unsafe
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Restaurants are already loaded in provider constructor
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }

  void _showRestaurantSelectionDialog(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Restaurant to Rate'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: restaurantProvider.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurantProvider.restaurants[index] as Restaurant;
              debugPrint('Restaurant type: ${restaurant.runtimeType}');
              debugPrint('Restaurant id: ${restaurant.id}');
              final hasReviewed = ratingProvider.hasUserReviewed(restaurant.id, authProvider.currentUser?['id'] ?? '');

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getRatingColor(_getRestaurantRating(restaurant)),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getRestaurantRating(restaurant).toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                title: Text(restaurant.name),
                subtitle: Text(restaurant.address),
                trailing: hasReviewed ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () {
                  Navigator.pop(context);
                  _showRatingDialog(context, restaurant, ratingProvider, authProvider);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Restaurant restaurant, RatingProvider ratingProvider, AuthProvider authProvider) {
    double selectedRating = 3.0;
    final TextEditingController reviewController = TextEditingController();
    final currentUser = authProvider.currentUser;
    final existingReview = ratingProvider.getUserReview(restaurant.id, currentUser?['id'] ?? '');

    if (existingReview != null) {
      selectedRating = existingReview.rating;
      reviewController.text = existingReview.reviewText ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingReview != null ? 'Update Your Review' : 'Rate ${restaurant.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate this restaurant?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starRating = index + 1;
                  return IconButton(
                    icon: Icon(
                      starRating <= selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = starRating.toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Share your experience...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (currentUser == null) return;

                final review = UserReview(
                  id: existingReview?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  restaurantId: restaurant.id,
                  userId: currentUser['id'],
                  userName: currentUser['name'] ?? currentUser['full_name'] ?? 'Anonymous',
                  rating: selectedRating,
                  reviewText: reviewController.text.trim().isEmpty ? null : reviewController.text.trim(),
                  createdAt: existingReview?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final success = await ratingProvider.addReview(review);
                if (success && context.mounted) {
                  // Update restaurant rating
                  final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
                  restaurantProvider.updateRestaurantRating(restaurant.id);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existingReview != null ? 'Review updated successfully!' : 'Thank you for your review!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(existingReview != null ? 'Update Review' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _rateRestaurant(BuildContext context, Restaurant restaurant, RatingProvider ratingProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _showRatingDialog(context, restaurant, ratingProvider, authProvider);
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: CitizenHomeScreen build method called on ${Theme.of(context).platform}');
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final ratingProvider = Provider.of<RatingProvider>(context);

    print('DEBUG: Providers - Restaurant: ${restaurantProvider.restaurants.length}, Auth: ${authProvider.isAuthenticated}, Role: ${authProvider.userRole}');
    print('DEBUG: Screen size: ${MediaQuery.of(context).size}');
    print('DEBUG: Device pixel ratio: ${MediaQuery.of(context).devicePixelRatio}');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo.small(),
            const SizedBox(width: 8),
            Flexible(child: Text(AppConstants.appName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        centerTitle: true,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
        actions: [
          const NotificationBell(),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  break;
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: Color(0xFF64748B)),
                    SizedBox(width: 12),
                    Text('Profile', style: TextStyle(fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20, color: Color(0xFF64748B)),
                    SizedBox(width: 12),
                    Text('Settings', style: TextStyle(fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Color(0xFFEF4444)),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant, color: Colors.orange, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${restaurantProvider.restaurants.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Restaurants',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.report, color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${reportProvider.reports.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Reports',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _showFilters
                    ? IconButton(
                        icon: const Icon(Icons.filter_list, color: Color(0xFF2563EB)),
                        onPressed: () {
                          setState(() => _showFilters = false);
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.filter_list_outlined),
                        onPressed: () {
                          setState(() => _showFilters = true);
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (_showFilters) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Safety Level',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Safe (80+)', 'safe'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Moderate (60-79)', 'moderate'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Unsafe (<60)', 'unsafe'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sort By',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: 'name', child: Text('Name')),
                        const DropdownMenuItem(value: 'rating', child: Text('User Rating')),
                        const DropdownMenuItem(value: 'inspection_score', child: Text('Inspection Score')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            
            // Restaurant List
            const Text(
              'Restaurants',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._buildRestaurantList(restaurantProvider, reportProvider, ratingProvider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRestaurantSelectionDialog(context);
        },
        icon: const Icon(Icons.star),
        label: const Text('Rate Restaurant'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRestaurantList(RestaurantProvider restaurantProvider, ReportProvider reportProvider, RatingProvider ratingProvider) {
    print('DEBUG: _buildRestaurantList called with ${restaurantProvider.restaurants.length} restaurants');
    var filteredRestaurants = restaurantProvider.restaurants
        .where((restaurant) =>
            restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            restaurant.address.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Apply safety filter
    filteredRestaurants = filteredRestaurants.where((restaurant) {
      final score = restaurant.lastInspectionScore ?? 0;
      switch (_filterBy) {
        case 'safe':
          return score >= 80;
        case 'moderate':
          return score >= 60 && score < 80;
        case 'unsafe':
          return score < 60;
        default:
          return true;
      }
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'rating':
        filteredRestaurants.sort((a, b) {
          final ratingA = _getRestaurantRating(a);
          final ratingB = _getRestaurantRating(b);
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'inspection_score':
        filteredRestaurants.sort((a, b) {
          final scoreA = a.lastInspectionScore ?? 0;
          final scoreB = b.lastInspectionScore ?? 0;
          return scoreB.compareTo(scoreA);
        });
        break;
      default:
        filteredRestaurants.sort((a, b) => a.name.compareTo(b.name));
    }

    print('DEBUG: Filtered restaurants: ${filteredRestaurants.length}');

    if (filteredRestaurants.isEmpty) {
      return [
        const SizedBox(height: 50),
        const Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No restaurants available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Restaurants will appear here once added by inspectors',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    return filteredRestaurants.map((restaurant) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showRestaurantDetails(context, restaurant, reportProvider, ratingProvider),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getRatingColorSingle(_getRestaurantRating(restaurant)).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _getRestaurantRating(restaurant).toStringAsFixed(1),
                          style: TextStyle(
                            color: _getRatingColorSingle(_getRestaurantRating(restaurant)),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  restaurant.address,
                                  style: const TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_getRestaurantStatus(restaurant)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRestaurantStatus(restaurant),
                        style: TextStyle(
                          color: _getStatusColor(_getRestaurantStatus(restaurant)),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_getRestaurantReportsCount(restaurant, reportProvider)} reports',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportScreen(
                              restaurantId: restaurant.id,
                              restaurantName: restaurant.name,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.report, size: 16),
                        label: const Text('Report Issue'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rateRestaurant(context, restaurant, ratingProvider),
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Rate Restaurant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helper methods for restaurant data
  double _getRestaurantRating(Restaurant restaurant) {
    // Use user rating if available, otherwise fall back to inspection score
    if (restaurant.userRating != null && restaurant.userRating! > 0) {
      return restaurant.userRating!;
    }
    return (restaurant.lastInspectionScore ?? 0) / 20.0; // Convert 0-100 to 0-5 scale
  }

  String _getRestaurantStatus(Restaurant restaurant) {
    final score = restaurant.lastInspectionScore ?? 0;
    if (score >= 90) return 'excellent';
    if (score >= 70) return 'good';
    if (score >= 50) return 'average';
    return 'poor';
  }

  int _getRestaurantReportsCount(Restaurant restaurant, ReportProvider reportProvider) {
    return reportProvider.reports.where((report) => report.restaurantId == restaurant.id).length;
  }

  List<Color> _getRatingColor(double rating) {
    if (rating >= 4.0) return [const Color(0xFF10B981), const Color(0xFF059669)];
    if (rating >= 3.0) return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
  }

  Color _getRatingColorSingle(double rating) {
    if (rating >= 4.0) return const Color(0xFF10B981);
    if (rating >= 3.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF10B981);
      case 'good':
        return const Color(0xFFF59E0B);
      case 'needs improvement':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'excellent':
        color = const Color(0xFF10B981);
        text = 'Excellent';
        break;
      case 'good':
        color = const Color(0xFF059669);
        text = 'Good';
        break;
      case 'average':
        color = const Color(0xFFF59E0B);
        text = 'Average';
        break;
      case 'poor':
        color = const Color(0xFFEF4444);
        text = 'Poor';
        break;
      default:
        color = const Color(0xFF94A3B8);
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  void _showRestaurantDetails(BuildContext context, Restaurant restaurant, ReportProvider reportProvider, RatingProvider ratingProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Restaurant Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getRatingColor(_getRestaurantRating(restaurant)),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _getRestaurantRating(restaurant).toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStatusChip(_getRestaurantStatus(restaurant)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.address,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailStat(
                            context,
                            'Total Reports',
                            _getRestaurantReportsCount(restaurant, reportProvider).toString(),
                            Icons.report_outlined,
                            const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailStat(
                            context,
                            'Inspections',
                            '2', // Mock data
                            Icons.search,
                            const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // User Reviews Section
                    if (restaurant.userReviewCount != null && restaurant.userReviewCount! > 0) ...[
                      const Text(
                        'User Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildReviewsSection(restaurant, ratingProvider),
                      const SizedBox(height: 32),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportScreen(
                                    restaurantId: restaurant.id,
                                    restaurantName: restaurant.name,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.report_outlined),
                            label: const Text('Report Issue'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              foregroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              _showRatingDialog(context, restaurant, ratingProvider, authProvider);
                            },
                            icon: const Icon(Icons.star),
                            label: const Text('Rate Restaurant'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(Restaurant restaurant, RatingProvider ratingProvider) {
    final reviews = ratingProvider.getReviewsForRestaurant(restaurant.id);
    final displayReviews = reviews.take(3); // Show only first 3 reviews

    return Column(
      children: displayReviews.map((review) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  review.reviewText!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatReviewDate(review.createdAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  Widget _buildDetailStat(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterBy == value;
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterBy = value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF2563EB),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class RestaurantDetailsSheet extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsSheet({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final score = restaurant.lastInspectionScore ?? 0;
    final scoreColor = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Restaurant Name
          Text(
            restaurant.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hygiene Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor),
            ),
            child: Row(
              children: [
                Icon(
                  _getScoreIcon(score),
                  color: scoreColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hygiene Score',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        score > 0 ? '$score/100' : 'Not Rated',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        _getScoreLabel(score),
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Details Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildDetailItem(Icons.location_on, 'Address', restaurant.address),
              if (restaurant.phone.isNotEmpty)
                _buildDetailItem(Icons.phone, 'Phone', restaurant.phone),
              if (restaurant.licenseNumber.isNotEmpty)
                _buildDetailItem(Icons.badge, 'License', restaurant.licenseNumber),
              if (restaurant.lastInspectionDate != null)
                _buildDetailItem(Icons.calendar_today, 'Last Inspection', 
                  restaurant.formattedLastInspectionDate),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Report Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportScreen(
                      restaurantId: restaurant.id,
                      restaurantName: restaurant.name,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Report an Issue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.verified;
    if (score >= 70) return Icons.check_circle;
    if (score >= 50) return Icons.warning;
    return Icons.error;
  }
}