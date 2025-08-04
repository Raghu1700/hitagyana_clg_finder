import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import './widgets/empty_saved_colleges_widget.dart';
import './widgets/saved_college_card_widget.dart';

class SavedCollegesScreen extends StatefulWidget {
  const SavedCollegesScreen({Key? key}) : super(key: key);

  @override
  State<SavedCollegesScreen> createState() => _SavedCollegesScreenState();
}

class _SavedCollegesScreenState extends State<SavedCollegesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isEditMode = false;
  bool _isCompareMode = false;
  bool _isLoading = true;
  String _sortBy = 'name';
  List<String> _selectedColleges = [];
  List<Map<String, dynamic>> _filteredColleges = [];
  List<Map<String, dynamic>> _savedColleges = [];
  List<String> _savedCollegeIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedColleges();
    _searchController.addListener(_filterColleges);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load saved college IDs from Firebase and get college data
  Future<void> _loadSavedColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get saved college IDs using AuthService (handles Firebase and local storage)
      _savedCollegeIds = await AuthService.getSavedColleges();

      if (_savedCollegeIds.isEmpty) {
        setState(() {
          _savedColleges = [];
          _filteredColleges = [];
          _isLoading = false;
        });
        return;
      }

      // Get all colleges from Firebase
      final allColleges = await FirebaseService.getAllColleges();

      // Filter only the saved colleges that exist in Firebase
      _savedColleges = allColleges.where((college) {
        return _savedCollegeIds.contains(college['id'].toString());
      }).toList();

      // Add metadata for saved colleges
      for (var college in _savedColleges) {
        college['dateAdded'] = DateTime.now();
        college['lastUpdated'] = DateTime.now();
        college['notes'] = '';
        college['isOffline'] = false;
      }

      setState(() {
        _filteredColleges = List.from(_savedColleges);
        _isLoading = false;
      });

      _filterColleges();
      print('✅ Loaded ${_savedColleges.length} saved colleges from Firebase');
    } catch (e) {
      print('Error loading saved colleges: $e');
      setState(() {
        _savedColleges = [];
        _filteredColleges = [];
        _isLoading = false;
      });
    }
  }

  void _filterColleges() {
    if (_searchController.text.isEmpty) {
      _filteredColleges = List.from(_savedColleges);
    } else {
      final query = _searchController.text.toLowerCase();
      _filteredColleges = _savedColleges.where((college) {
        final name = (college['name']?.toString() ?? '').toLowerCase();
        final location = (college['location']?.toString() ?? '').toLowerCase();
        final shortName =
            (college['shortName']?.toString() ?? '').toLowerCase();

        return name.contains(query) ||
            location.contains(query) ||
            shortName.contains(query);
      }).toList();
    }
    _sortColleges();
  }

  void _sortColleges() {
    switch (_sortBy) {
      case 'name':
        _filteredColleges.sort((a, b) => (a["name"]?.toString() ?? '')
            .compareTo((b["name"]?.toString() ?? '')));
        break;
      case 'location':
        _filteredColleges.sort((a, b) => (a["location"]?.toString() ?? '')
            .compareTo((b["location"]?.toString() ?? '')));
        break;
      case 'ranking':
        _filteredColleges.sort(
            (a, b) => (a["ranking"] ?? 999).compareTo(b["ranking"] ?? 999));
        break;
      case 'fees':
        _filteredColleges.sort((a, b) {
          final aFees = int.tryParse((a["totalFee"]?.toString() ?? '0')
                  .replaceAll('₹', '')
                  .replaceAll(',', '')) ??
              0;
          final bFees = int.tryParse((b["totalFee"]?.toString() ?? '0')
                  .replaceAll('₹', '')
                  .replaceAll(',', '')) ??
              0;
          return aFees.compareTo(bFees);
        });
        break;
      case 'dateAdded':
        _filteredColleges.sort((a, b) {
          final aDate = a["dateAdded"] as DateTime? ?? DateTime.now();
          final bDate = b["dateAdded"] as DateTime? ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        break;
    }
  }

  Future<void> _refreshColleges() async {
    await _loadSavedColleges();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _isCompareMode = false;
        _selectedColleges.clear();
      }
    });
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
      if (!_isCompareMode) {
        _selectedColleges.clear();
      }
    });
  }

  void _toggleCollegeSelection(String collegeId) {
    setState(() {
      if (_selectedColleges.contains(collegeId)) {
        _selectedColleges.remove(collegeId);
      } else {
        _selectedColleges.add(collegeId);
      }
    });
  }

  void _removeCollege(String collegeId) async {
    if (collegeId.isEmpty) return;

    try {
      // Remove using AuthService (handles Firebase and local storage)
      final success = await AuthService.unsaveCollege(collegeId);

      if (success) {
        await _loadSavedColleges(); // Reload the list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('College removed from saved list'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                await AuthService.saveCollege(collegeId);
                await _loadSavedColleges();
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing college: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareCollege(Map<String, dynamic> college) {
    final collegeName = college["name"]?.toString() ?? "Unknown College";
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing $collegeName (Feature coming soon!)'),
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> college) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share College'),
              onTap: () {
                Navigator.pop(context);
                _shareCollege(college);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/college-details-screen',
                  arguments: college,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Remove from Saved',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                final collegeId = college["id"]?.toString() ?? '';
                if (collegeId.isNotEmpty) {
                  _removeCollege(collegeId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isAnonymous = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: AppTheme.almond,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Remove back button since this is main page
        title: Text(
          "Saved Colleges",
          style: TextStyle(
            color: AppTheme.tyrianPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Navigation to search screen
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/college-search-dashboard');
            },
            icon: Icon(
              Icons.search,
              color: AppTheme.byzantium,
              size: 24,
            ),
            tooltip: 'Search Colleges',
          ),
          if (_savedColleges.isNotEmpty)
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(
                _isEditMode ? Icons.close : Icons.edit,
                color: AppTheme.byzantium,
                size: 24,
              ),
              tooltip: _isEditMode ? 'Cancel Edit' : 'Edit Mode',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.byzantium),
                ),
              )
            : _savedColleges.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Search and Filter Section
                      Container(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          children: [
                            // Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.pureWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search saved colleges...',
                                  prefixIcon: Icon(Icons.search,
                                      color: AppTheme.mediumGray),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                          icon: Icon(Icons.clear,
                                              color: AppTheme.mediumGray),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // Sort Options
                            Row(
                              children: [
                                Text(
                                  'Sort by: ',
                                  style: TextStyle(
                                    color: AppTheme.mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _sortBy,
                                    isExpanded: true,
                                    underline: Container(),
                                    items: [
                                      DropdownMenuItem(
                                          value: 'name', child: Text('Name')),
                                      DropdownMenuItem(
                                          value: 'location',
                                          child: Text('Location')),
                                      DropdownMenuItem(
                                          value: 'dateAdded',
                                          child: Text('Date Added')),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _sortBy = value;
                                        });
                                        _sortColleges();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // College List
                      Expanded(
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _loadSavedColleges,
                          color: AppTheme.byzantium,
                          child: _filteredColleges.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 15.w,
                                        color: AppTheme.lightGray,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'No colleges match your search',
                                        style: TextStyle(
                                          color: AppTheme.mediumGray,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  itemCount: _filteredColleges.length,
                                  itemBuilder: (context, index) {
                                    final college = _filteredColleges[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 3.h),
                                      child: SavedCollegeCardWidget(
                                        college: college,
                                        isEditMode: _isEditMode,
                                        isCompareMode: _isCompareMode,
                                        isSelected: _selectedColleges.contains(
                                            college['id']?.toString() ?? ''),
                                        onToggleSelection: () {
                                          _toggleCollegeSelection(
                                              college['id']?.toString() ?? '');
                                        },
                                        onRemove: () => _removeCollege(
                                            college['id']?.toString() ?? ''),
                                        onShare: () => _shareCollege(college),
                                        onViewDetails: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/college-details-screen',
                                            arguments: college,
                                          );
                                        },
                                        onLongPress: () =>
                                            _showContextMenu(college),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: _isCompareMode && _selectedColleges.length >= 2
          ? FloatingActionButton.extended(
              onPressed: () {
                // Implement comparison functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('College comparison feature coming soon!'),
                    backgroundColor: AppTheme.byzantium,
                  ),
                );
              },
              backgroundColor: AppTheme.byzantium,
              icon: Icon(
                Icons.compare,
                color: AppTheme.almond,
                size: 20,
              ),
              label: Text(
                'Compare (${_selectedColleges.length})',
                style: TextStyle(color: AppTheme.almond),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return EmptySavedCollegesWidget(
      onExplorePressed: () {
        Navigator.pushNamed(context, '/college-search-dashboard');
      },
    );
  }
}
