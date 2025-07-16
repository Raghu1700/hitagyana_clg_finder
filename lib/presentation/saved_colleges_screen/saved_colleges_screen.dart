import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/college_model.dart';
import '../../data/services/firebase_college_service.dart';
import '../../data/services/firebase_saved_colleges_service.dart';
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
  String _sortBy = 'name';
  List<String> _selectedColleges = [];
  List<CollegeModel> _filteredColleges = [];
  bool _isLoading = true;

  // Firebase services
  final FirebaseCollegeService _collegeService = FirebaseCollegeService();
  final FirebaseSavedCollegesService _savedCollegeService =
      FirebaseSavedCollegesService();

  // College data
  List<CollegeModel> _savedColleges = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterColleges);
    _loadSavedColleges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await _savedCollegeService.getSavedColleges();

      setState(() {
        _savedColleges = colleges;
        _filteredColleges = List.from(colleges);
        _sortColleges();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved colleges: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterColleges() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredColleges = _savedColleges.where((college) {
        final name = college.name.toLowerCase();
        final location = college.location.toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
      _sortColleges();
    });
  }

  void _sortColleges() {
    switch (_sortBy) {
      case 'name':
        _filteredColleges.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'ranking':
        _filteredColleges.sort((a, b) => a.ranking.compareTo(b.ranking));
        break;
      case 'fees':
        _filteredColleges.sort((a, b) {
          final aFees =
              int.parse(a.totalFee.replaceAll('₹', '').replaceAll(',', ''));
          final bFees =
              int.parse(b.totalFee.replaceAll('₹', '').replaceAll(',', ''));
          return aFees.compareTo(bFees);
        });
        break;
      case 'dateAdded':
        _filteredColleges.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  Future<void> _removeCollege(String collegeId) async {
    try {
      await _savedCollegeService.unsaveCollege(collegeId);

      setState(() {
        _savedColleges.removeWhere((college) => college.id == collegeId);
        _filteredColleges.removeWhere((college) => college.id == collegeId);
        _selectedColleges.remove(collegeId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('College removed from saved list'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Re-save the college
              try {
                await _savedCollegeService.saveCollege(collegeId);
                _loadSavedColleges(); // Reload saved colleges
              } catch (e) {
                print('Error re-saving college: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error removing college: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove college')),
      );
    }
  }

  void _shareCollege(CollegeModel college) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${college.name}')),
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

  Future<void> _showCompareView() async {
    if (_selectedColleges.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least 2 colleges to compare')),
      );
      return;
    }

    try {
      final comparison =
          await _savedCollegeService.compareColleges(_selectedColleges);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => ComparisonView(comparison: comparison),
      );

      // Save comparison history
      await _savedCollegeService.saveComparisonHistory(_selectedColleges);
    } catch (e) {
      print('Error comparing colleges: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to compare colleges')),
      );
    }
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
                                    college: {
                                      "id": college.id,
                                      "name": college.name,
                                      "shortName": college.shortName,
                                      "location": college.location,
                                      "ranking": college.ranking,
                                      "logo": college.logo,
                                      "tuitionFees": college.tuitionFee,
                                      "collegeFees": college.collegeFee,
                                      "hostelFees": college.hostelFee,
                                      "totalFees": college.totalFee,
                                      "website": college.website,
                                      "dateAdded": college.createdAt,
                                      "lastUpdated": college.updatedAt,
                                      "notes": "",
                                      "isOffline": false,
                                    },
                                    isEditMode: _isEditMode,
                                    isCompareMode: _isCompareMode,
                                    isSelected:
                                        _selectedColleges.contains(college.id),
                                    onToggleSelection: () =>
                                        _toggleCollegeSelection(college.id),
                                    onRemove: () => _removeCollege(college.id),
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

  void _showContextMenu(CollegeModel college) {
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

  void _showAddNotesDialog(CollegeModel college) {
    final TextEditingController notesController = TextEditingController();
    notesController.text = college.notes ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your notes about ${college.name}...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _savedCollegeService.updateCollegeNotes(
                    college.id, notesController.text);
                _loadSavedColleges(); // Reload saved colleges to update notes
              } catch (e) {
                print('Error updating notes: $e');
              }
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
  final Map<String, dynamic> comparison;

  const ComparisonView({Key? key, required this.comparison}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> colleges = comparison['colleges'] as List;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'College Comparison',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: colleges.map((college) {
                  return CompareCollegeCardWidget(
                    college: college as Map<String, dynamic>,
                  );
                }).toList(),
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
