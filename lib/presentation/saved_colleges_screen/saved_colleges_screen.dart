import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../services/firebase_service.dart';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load saved college IDs from SharedPreferences and fetch college data from Firebase
  Future<void> _loadSavedColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load saved college IDs from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _savedCollegeIds = prefs.getStringList('savedColleges') ?? [];

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
    } catch (e) {
      print('Error loading saved colleges: $e');
      setState(() {
        _savedColleges = [];
        _filteredColleges = [];
        _isLoading = false;
      });
    }
  }

  // Save a college ID to SharedPreferences
  Future<void> _saveCollegeId(String collegeId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_savedCollegeIds.contains(collegeId)) {
      _savedCollegeIds.add(collegeId);
      await prefs.setStringList('savedColleges', _savedCollegeIds);
    }
  }

  // Remove a college ID from SharedPreferences
  Future<void> _removeSavedCollegeId(String collegeId) async {
    final prefs = await SharedPreferences.getInstance();
    _savedCollegeIds.remove(collegeId);
    await prefs.setStringList('savedColleges', _savedCollegeIds);
  }

  void _filterColleges() {
    if (_searchController.text.isEmpty) {
      _filteredColleges = List.from(_savedColleges);
    } else {
      final query = _searchController.text.toLowerCase();
      _filteredColleges = _savedColleges.where((college) {
        final name = (college['name'] ?? '').toString().toLowerCase();
        final location = (college['location'] ?? '').toString().toLowerCase();
        final shortName = (college['shortName'] ?? '').toString().toLowerCase();

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
        _filteredColleges.sort((a, b) => (a["name"] ?? '')
            .toString()
            .compareTo((b["name"] ?? '').toString()));
        break;
      case 'ranking':
        _filteredColleges.sort(
            (a, b) => (a["ranking"] ?? 999).compareTo(b["ranking"] ?? 999));
        break;
      case 'fees':
        _filteredColleges.sort((a, b) {
          final aFees = int.tryParse((a["totalFee"] ?? '0')
                  .toString()
                  .replaceAll('₹', '')
                  .replaceAll(',', '')) ??
              0;
          final bFees = int.tryParse((b["totalFee"] ?? '0')
                  .toString()
                  .replaceAll('₹', '')
                  .replaceAll(',', '')) ??
              0;
          return aFees.compareTo(bFees);
        });
        break;
      case 'dateAdded':
        _filteredColleges.sort((a, b) =>
            (b["dateAdded"] as DateTime).compareTo(a["dateAdded"] as DateTime));
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
    await _removeSavedCollegeId(collegeId);
    await _loadSavedColleges(); // Reload the list

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('College removed from saved list'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _saveCollegeId(collegeId);
            await _loadSavedColleges();
          },
        ),
      ),
    );
  }

  void _shareCollege(Map<String, dynamic> college) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${college["name"]}')),
    );
  }

  void _exportSavedList() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting saved colleges list')),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildSortOption('Name', 'name'),
            _buildSortOption('Ranking', 'ranking'),
            _buildSortOption('Fees', 'fees'),
            _buildSortOption('Date Added', 'dateAdded'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: _sortBy == value
          ? CustomIconWidget(
              iconName: 'check',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            )
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortColleges();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showCompareView() {
    if (_selectedColleges.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least 2 colleges to compare')),
      );
      return;
    }

    final selectedCollegeData = _savedColleges
        .where((college) => _selectedColleges.contains(college["id"]))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ComparisonView(colleges: selectedCollegeData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Saved Colleges'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          if (_savedColleges.isNotEmpty)
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(_isEditMode ? 'Done' : 'Edit'),
            ),
          if (_savedColleges.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    _exportSavedList();
                    break;
                  case 'sort':
                    _showSortOptions();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'sort',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('Sort'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('Export List'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _savedColleges.isEmpty
              ? EmptySavedCollegesWidget(
                  onExplorePressed: () {
                    Navigator.pushNamed(context, '/college-search-dashboard');
                  },
                )
              : Column(
                  children: [
                    // Search and Filter Section
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search saved colleges...',
                              prefixIcon: CustomIconWidget(
                                iconName: 'search',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                      icon: CustomIconWidget(
                                        iconName: 'clear',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        size: 20,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          // Compare Mode Toggle
                          if (_isEditMode) ...[
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleCompareMode,
                                    icon: CustomIconWidget(
                                      iconName:
                                          _isCompareMode ? 'close' : 'compare',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 18,
                                    ),
                                    label: Text(_isCompareMode
                                        ? 'Exit Compare'
                                        : 'Compare Mode'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isCompareMode
                                          ? AppTheme
                                              .lightTheme.colorScheme.error
                                          : AppTheme.lightTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Colleges List
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refreshColleges,
                        child: _filteredColleges.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'search_off',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No colleges found',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search terms',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredColleges.length,
                                itemBuilder: (context, index) {
                                  final college = _filteredColleges[index];
                                  return SavedCollegeCardWidget(
                                    college: college,
                                    isEditMode: _isEditMode,
                                    isCompareMode: _isCompareMode,
                                    isSelected: _selectedColleges
                                        .contains(college["id"]),
                                    onToggleSelection: () =>
                                        _toggleCollegeSelection(college["id"]),
                                    onRemove: () =>
                                        _removeCollege(college["id"]),
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
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _isCompareMode && _selectedColleges.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCompareView,
              icon: CustomIconWidget(
                iconName: 'compare_arrows',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Compare (${_selectedColleges.length})'),
            )
          : null,
    );
  }

  void _showContextMenu(Map<String, dynamic> college) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'vertical_align_top',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Move to Top'),
              onTap: () {
                Navigator.pop(context);
                // Implement move to top functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Add Notes'),
              onTap: () {
                Navigator.pop(context);
                _showAddNotesDialog(college);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notification_add',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Set Reminder'),
              onTap: () {
                Navigator.pop(context);
                // Implement set reminder functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNotesDialog(Map<String, dynamic> college) {
    final TextEditingController notesController = TextEditingController();
    notesController.text = college["notes"] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your notes about ${college["name"]}...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                college["notes"] = notesController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class ComparisonView extends StatelessWidget {
  final List<Map<String, dynamic>> colleges;

  const ComparisonView({Key? key, required this.colleges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compare Colleges',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: colleges
                    .map((college) => CompareCollegeCardWidget(
                          college: college,
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompareCollegeCardWidget extends StatelessWidget {
  final Map<String, dynamic> college;

  const CompareCollegeCardWidget({Key? key, required this.college})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College Header
              Row(
                children: [
                  CustomImageWidget(
                    imageUrl: college["logo"],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college["shortName"],
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          college["location"],
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Ranking
              _buildCompareItem('Ranking', '#${college["ranking"]}'),
              _buildCompareItem('Tuition Fees', college["tuitionFees"]),
              _buildCompareItem('College Fees', college["collegeFees"]),
              _buildCompareItem('Hostel Fees', college["hostelFees"]),
              _buildCompareItem('Total Fees', college["totalFees"],
                  isHighlight: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompareItem(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isHighlight
                ? AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  )
                : AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }
}
