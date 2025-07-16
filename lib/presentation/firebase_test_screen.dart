import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../data/services/firebase_service.dart';
import '../data/services/firebase_college_service.dart';
import '../core/app_export.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseCollegeService _collegeService = FirebaseCollegeService();
  bool _isLoading = true;
  Map<String, dynamic> _firebaseStatus = {};
  String _testMessage = '';
  bool _isTestingColleges = false;
  int _collegeCount = 0;
  String _collegeTestMessage = '';
  bool _isUploadingColleges = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    setState(() {
      _isLoading = true;
      _testMessage = 'Testing Firebase connection...';
    });

    try {
      final status = await _firebaseService.getFirebaseStatus();
      setState(() {
        _firebaseStatus = status;
        _isLoading = false;

        if (status['error'] != null) {
          _testMessage = 'Error: ${status['error']}';
        } else if (status['initialized'] == true &&
            status['firestore'] == true &&
            status['auth'] == true &&
            status['analytics'] == true) {
          _testMessage = 'Firebase is properly integrated and working!';
        } else {
          _testMessage =
              'Firebase integration has issues. Check the status below.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _testMessage = 'Error testing Firebase: $e';
      });
    }
  }

  Future<void> _testCollegeCollection() async {
    setState(() {
      _isTestingColleges = true;
      _collegeTestMessage = 'Testing college collection...';
      _collegeCount = 0;
    });

    try {
      // Initialize colleges if needed
      await _collegeService.initializeCollegesCollection();

      // Get all colleges
      final colleges = await _collegeService.getAllColleges();

      setState(() {
        _collegeCount = colleges.length;
        _collegeTestMessage =
            'Successfully retrieved ${colleges.length} colleges from Firestore!';
        _isTestingColleges = false;
      });
    } catch (e) {
      setState(() {
        _collegeTestMessage = 'Error testing college collection: $e';
        _isTestingColleges = false;
      });
    }
  }

  Future<void> _uploadCollegesToFirestore() async {
    setState(() {
      _isUploadingColleges = true;
      _collegeTestMessage = 'Uploading colleges to Firestore...';
    });

    try {
      // Upload colleges to Firestore
      await _collegeService.uploadCollegesToFirestore();

      // Get all colleges to verify
      final colleges = await _collegeService.getAllColleges();

      setState(() {
        _collegeCount = colleges.length;
        _collegeTestMessage =
            'Successfully uploaded ${colleges.length} colleges to Firestore!';
        _isUploadingColleges = false;
      });
    } catch (e) {
      setState(() {
        _collegeTestMessage = 'Error uploading colleges to Firestore: $e';
        _isUploadingColleges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Integration Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkFirebaseStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading ? _buildLoadingState() : _buildStatusDisplay(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(_testMessage),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay() {
    final bool isSuccessful = _firebaseStatus['error'] == null &&
        (_firebaseStatus['initialized'] ?? false) &&
        (_firebaseStatus['firestore'] ?? false) &&
        (_firebaseStatus['auth'] ?? false) &&
        (_firebaseStatus['analytics'] ?? false);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isSuccessful ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSuccessful ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isSuccessful ? Icons.check_circle : Icons.error,
                    color: isSuccessful ? Colors.green : Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _testMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSuccessful
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Firebase Status:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
              'Firebase Initialized', _firebaseStatus['initialized'] ?? false),
          _buildStatusItem(
              'Firestore Connection', _firebaseStatus['firestore'] ?? false),
          _buildStatusItem(
              'Authentication Service', _firebaseStatus['auth'] ?? false),
          _buildStatusItem(
              'Analytics Service', _firebaseStatus['analytics'] ?? false),

          if (_firebaseStatus['error'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Error: ${_firebaseStatus['error']}',
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // College Collection Test Section
          const Text(
            'College Collection Test:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isTestingColleges ? null : _testCollegeCollection,
                icon: Icon(
                    _isTestingColleges ? Icons.hourglass_empty : Icons.school),
                label: Text(_isTestingColleges
                    ? 'Testing...'
                    : 'Test College Collection'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed:
                    _isUploadingColleges ? null : _uploadCollegesToFirestore,
                icon: Icon(_isUploadingColleges
                    ? Icons.hourglass_empty
                    : Icons.upload),
                label: Text(
                    _isUploadingColleges ? 'Uploading...' : 'Upload Colleges'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isTestingColleges)
            Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Testing college collection...'),
                ],
              ),
            )
          else if (_collegeTestMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _collegeCount > 0
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _collegeCount > 0 ? Colors.blue : Colors.orange,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _collegeCount > 0 ? Icons.check_circle : Icons.warning,
                    color: _collegeCount > 0 ? Colors.blue : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _collegeTestMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _collegeCount > 0
                          ? Colors.blue.shade800
                          : Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_collegeCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'College collection is ready for use!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to App'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            status ? 'Connected' : 'Failed',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
