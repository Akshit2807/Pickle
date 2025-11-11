import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// --- CONSTANTS AND UTILITIES ---
const Color _primaryRed = Color(0xFFee403a);
const Color _followGreen = Color(0xFF6dd66c);

// --- DATA MODEL ---
class Profile {
  final String imageUrl;
  final String name;
  final String description;
  final List<String> qualities;

  Profile({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.qualities,
  });
}

// --- APP BAR ---
class _StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color primaryColor;
  final VoidCallback onFilterPressed;
  const _StandardAppBar({required this.primaryColor, required this.onFilterPressed, super.key});

  @override
  Widget build(BuildContext context) => AppBar(
        title: const Text('Pickle', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --- PLACEHOLDER SCREEN ---
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title, super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 24)),
      );
}

// -----------------------------------------------------------------------------
// --- MAIN DASHBOARD SCREEN ---
// -----------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    SystemChrome.setSystemUIOverlayStyle(
      index == 0 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  void _showFiltersBottomSheet() {}

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : _StandardAppBar(primaryColor: _primaryRed, onFilterPressed: _showFiltersBottomSheet),
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CreatorProfileScreen(),
          _PlaceholderScreen(title: 'My Chats'),
          _PlaceholderScreen(title: 'Likes'),
          _PlaceholderScreen(title: 'Exploring'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- SWIPE CARD WIDGET ---
// -----------------------------------------------------------------------------
class _SwipeCard extends StatefulWidget {
  final Profile profile;
  final bool isTopCard;
  final ValueChanged<Profile> onSwipedLeft;
  final ValueChanged<Profile> onSwipedRight;
  final ValueChanged<Profile> onSwipedUp;
  final ValueChanged<Profile> onSwipedDown;

  const _SwipeCard({
    required this.profile,
    required this.isTopCard,
    required this.onSwipedLeft,
    required this.onSwipedRight,
    required this.onSwipedUp,
    required this.onSwipedDown,
    super.key,
  });

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard> {
  Offset _dragPosition = Offset.zero;
  double _rotation = 0.0;
  double _scale = 1.0;
  static const double _dismissThreshold = 100.0;
  static const double _rotationFactor = 0.005;
  static const double _maxRotation = pi / 12;

  void _onPanStart(DragStartDetails details) {
    if (!widget.isTopCard) return;
    setState(() {
      _dragPosition = Offset.zero;
      _rotation = 0.0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isTopCard) return;
    setState(() {
      _dragPosition += details.delta;
      _rotation = (_dragPosition.dx * _rotationFactor).clamp(-_maxRotation, _maxRotation);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTopCard) return;
    final double x = _dragPosition.dx;
    final double y = _dragPosition.dy;
    final size = MediaQuery.of(context).size;

    if (x.abs() > _dismissThreshold) {
      if (x > 0) {
        _animateAndDismiss(size.width);
        widget.onSwipedRight(widget.profile);
      } else {
        _animateAndDismiss(-size.width);
        widget.onSwipedLeft(widget.profile);
      }
    } else if (y.abs() > _dismissThreshold) {
      if (y > 0) {
        _animateAndDismiss(0, y: size.height);
        widget.onSwipedDown(widget.profile);
      } else {
        _animateAndDismiss(0, y: -size.height);
        widget.onSwipedUp(widget.profile);
      }
    } else {
      _resetCardPosition();
    }
  }

  void _animateAndDismiss(double endX, {double y = 0.0}) {
    setState(() {
      _dragPosition = Offset(endX, y);
      _rotation = endX > 0
          ? _maxRotation
          : (endX < 0 ? -_maxRotation : (y > 0 ? pi / 24 : -pi / 24));
    });
  }

  void _resetCardPosition() {
    setState(() {
      _dragPosition = Offset.zero;
      _rotation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool interactive = widget.isTopCard;

    return GestureDetector(
      onPanStart: interactive ? _onPanStart : null,
      onPanUpdate: interactive ? _onPanUpdate : null,
      onPanEnd: interactive ? _onPanEnd : null,
      child: AnimatedContainer(
        duration: _dragPosition == Offset.zero
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        curve: Curves.easeOut,
        alignment: Alignment.center,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(_dragPosition.dx, _dragPosition.dy)
            ..rotateZ(_rotation)
            ..scale(_scale),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image with improved error handling
                Image.network(
                  widget.profile.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.person, color: Colors.white, size: 60),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
                // 2. Gradient Overlay
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.4, 0.65, 0.85, 1.0],
                    ),
                  ),
                ),
                // 3. Text Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.profile.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.profile.qualities
                            .map(
                              (quality) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4)),
                                ),
                                child: Text(
                                  quality,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- CREATOR PROFILE SCREEN ---
// -----------------------------------------------------------------------------
class CreatorProfileScreen extends StatefulWidget {
  const CreatorProfileScreen({super.key});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  List<Profile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    _profiles = [
      Profile(
        imageUrl:
            'https://images.unsplash.com/photo-1596707328100-c9a174092b3f?q=80&w=1964&auto=format&fit=crop',
        name: 'Amanda Lourence',
        description:
            'My name is Amanda, you can call me. I\'m 19 years old and live in Jakarta. Want to get acquainted?',
        qualities: [
          'Shopping',
          'Music',
          'Coffee',
          'Books',
          'Piano',
          'Engineering',
          'Movies',
          'Travel'
        ],
      ),
      Profile(
        imageUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
        name: 'Jane Doe',
        description:
            'Passionate artist and nature lover. Always looking for new inspiration and adventures!',
        qualities: ['Art', 'Nature', 'Photography', 'Hiking', 'Cooking'],
      ),
      Profile(
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop',
        name: 'John Smith',
        description:
            'Software engineer by day, aspiring chef by night. Enjoy coding, good food, and exploring new cities.',
        qualities: ['Coding', 'Cooking', 'Travel', 'Tech', 'Foodie'],
      ),
    ];
    _profiles = _profiles.reversed.toList();
    setState(() {});
  }

  void _onCardSwiped(Profile profile, String direction) {
    debugPrint('Swiped $direction: ${profile.name}');
    setState(() {
      _profiles.remove(profile);
      if (_profiles.isEmpty) _loadProfiles();
    });
  }

  void _handleButtonPress(String action) {
    if (_profiles.isNotEmpty) {
      final currentProfile = _profiles.first;
      debugPrint('Button "$action" pressed for: ${currentProfile.name}');
      setState(() {
        final removedProfile = _profiles.removeAt(0);
        if (_profiles.isEmpty) _loadProfiles();

        if (action == 'Close') {
          _onCardSwiped(removedProfile, 'Left (Button)');
        } else if (action == 'Like (Flame)') {
          _onCardSwiped(removedProfile, 'Right (Button)');
        } else if (action == 'Favorite') {
          _onCardSwiped(removedProfile, 'Up (Button)');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double bottomActionHeight = 110.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ..._profiles.asMap().entries.map((entry) {
            int index = entry.key;
            Profile profile = entry.value;
            bool isTopCard = index == 0;
            double scale = 1.0 - (index * 0.05).clamp(0.0, 0.1);
            double verticalOffset = (index * 10).toDouble();

            return Positioned.fill(
              bottom: bottomActionHeight + MediaQuery.of(context).padding.bottom,
              child: Padding(
                padding: EdgeInsets.only(top: verticalOffset, left: index * 5.0, right: index * 5.0),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: _SwipeCard(
                    profile: profile,
                    isTopCard: isTopCard,
                    onSwipedLeft: (p) => _onCardSwiped(p, 'Left'),
                    onSwipedRight: (p) => _onCardSwiped(p, 'Right'),
                    onSwipedUp: (p) => _onCardSwiped(p, 'Up'),
                    onSwipedDown: (p) => _onCardSwiped(p, 'Down'),
                  ),
                ),
              ),
            );
          }).toList(),
          if (_profiles.isEmpty)
            Center(
              child: Text('No more profiles to show!',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white, size: 28), onPressed: () {}),
              ],
            ),
          ),
          Positioned(
            bottom: 20.0 + MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.grey.shade700,
                    onPressed: () => _handleButtonPress('Close'),
                  ),
                  _buildActionButton(
                    icon: Icons.local_fire_department,
                    color: _primaryRed,
                    onPressed: () => _handleButtonPress('Like (Flame)'),
                    isLarge: true,
                  ),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: _followGreen,
                    onPressed: () => _handleButtonPress('Favorite'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return Container(
      width: isLarge ? 70 : 55,
      height: isLarge ? 70 : 55,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: isLarge ? 35 : 28), onPressed: onPressed),
    );
  }
}
