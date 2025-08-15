import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dashboard Screen (Complete)
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.tune, color: Color(0xFFee403a)),
          onPressed: _showFiltersBottomSheet,
        ),
        title: Text(
          'Pickle',
          style: TextStyle(
            color: Color(0xFFee403a),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFFee403a)),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildSwipeScreen(),
          _buildPlaceholderScreen('My Chats'),
          _buildPlaceholderScreen('Likes'),
          _buildPlaceholderScreen('Exploring'),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFee403a),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'My Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'Likes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Exploring',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeScreen() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Stack(
                children: [
                  // Background cards
                  for (int i = 2; i >= 0; i--)
                    Transform.translate(
                      offset: Offset(0, i * 10.0),
                      child: Transform.scale(
                        scale: 1 - (i * 0.05),
                        child: _buildDatingCard(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        _buildActionButtons(),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDatingCard(int index) {
    final List<Map<String, dynamic>> dummyProfiles = [
      {
        'name': 'Sarah',
        'age': 25,
        'distance': 5,
        'bio': 'Love traveling and photography 📸',
        'interests': ['Travel', 'Photography', 'Coffee'],
        'color': Color(0xFFf2c75a),
      },
      {
        'name': 'Emma',
        'age': 23,
        'distance': 8,
        'bio': 'Yoga instructor & dog lover 🐕',
        'interests': ['Yoga', 'Dogs', 'Hiking'],
        'color': Color(0xFFf86f54),
      },
      {
        'name': 'Lily',
        'age': 27,
        'distance': 3,
        'bio': 'Foodie exploring the city 🍕',
        'interests': ['Food', 'Music', 'Art'],
        'color': Color(0xFFee403a),
      },
    ];

    final profile = dummyProfiles[index % dummyProfiles.length];

    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: index == 0 ? _cardSlideAnimation.value * MediaQuery.of(context).size.width : Offset.zero,
          child: Transform.scale(
            scale: index == 0 ? _cardScaleAnimation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        profile['color'].withOpacity(0.3),
                        profile['color'],
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Profile image placeholder
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: profile['color'],
                          ),
                        ),
                      ),
                      // Profile info
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${profile['name']}, ${profile['age']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    '${profile['distance']} km',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                profile['bio'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: (profile['interests'] as List<String>).map((interest) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      interest,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.grey[400]!,
            onTap: () => _swipeCard(false),
          ),
          _buildActionButton(
            icon: Icons.star,
            color: Color(0xFFf2c75a),
            onTap: () => _showSuperLikeDialog(),
            isLarge: true,
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: Color(0xFFee403a),
            onTap: () => _swipeCard(true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    final size = isLarge ? 65.0 : 55.0;
    final iconSize = isLarge ? 30.0 : 25.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Coming Soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _swipeCard(bool isLike) {
    _cardController.forward().then((_) {
      // Reset animation and show next card
      _cardController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLike ? 'Liked! 💕' : 'Passed'),
          backgroundColor: isLike ? Color(0xFFee403a) : Colors.grey[600],
          duration: Duration(milliseconds: 800),
        ),
      );
    });

    HapticFeedback.lightImpact();
  }

  void _showSuperLikeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star, color: Color(0xFFf2c75a)),
            SizedBox(width: 10),
            Text('Super Like'),
          ],
        ),
        content: Text('Send a Super Like to stand out! This is a premium feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _swipeCard(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Super Like sent! ⭐'),
                  backgroundColor: Color(0xFFf2c75a),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFf2c75a),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Send Super Like', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFee403a),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age Range: 18 - 30',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    RangeSlider(
                      values: RangeValues(18, 30),
                      min: 18,
                      max: 65,
                      activeColor: Color(0xFFee403a),
                      onChanged: (values) {},
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Distance: 25 km',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: 25,
                      min: 1,
                      max: 100,
                      activeColor: Color(0xFFee403a),
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Interested In',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ['Everyone', 'Men', 'Women', 'Non-binary'].map((option) {
                        return FilterChip(
                          label: Text(option),
                          selected: option == 'Everyone',
                          onSelected: (selected) {},
                          selectedColor: Color(0xFFee403a).withOpacity(0.2),
                          checkmarkColor: Color(0xFFee403a),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFee403a)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Reset', style: TextStyle(color: Color(0xFFee403a))),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFee403a),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
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
}