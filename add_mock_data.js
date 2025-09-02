// Firebase Admin SDK script to add mock college data
// Run this with: node add_mock_data.js

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = {
  "type": "service_account",
  "project_id": "hitagyana-clg-finder",
  "private_key_id": "your-private-key-id",
  "private_key": "your-private-key",
  "client_email": "firebase-adminsdk-xxxxx@hitagyana-clg-finder.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40hitagyana-clg-finder.iam.gserviceaccount.com"
};

// For testing, we'll use the project ID directly
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'hitagyana-clg-finder'
});

const db = admin.firestore();

// Mock college data
const mockColleges = [
  {
    id: 'iit-delhi',
    name: 'Indian Institute of Technology Delhi',
    shortName: 'IIT Delhi',
    location: 'New Delhi, Delhi',
    ranking: 2,
    logo: 'https://upload.wikimedia.org/wikipedia/en/f/fd/Indian_Institute_of_Technology_Delhi_Logo.svg',
    tuitionFee: '₹2,50,000',
    collegeFee: '₹50,000',
    hostelFee: '₹75,000',
    totalFee: '₹3,75,000',
    courses: [
      'Computer Science & Engineering',
      'Mechanical Engineering', 
      'Electrical Engineering',
      'Civil Engineering',
      'Chemical Engineering'
    ],
    rating: 4.8,
    reviewCount: 1250,
    website: 'https://www.iitd.ac.in',
    established: 1961,
    type: 'Government',
    accreditation: 'NAAC A++',
    campusSize: '320 acres',
    studentCount: 8500,
    facultyCount: 450,
    placementRate: '95%',
    averagePackage: '₹18,00,000',
    facilities: [
      'Library',
      'Hostels', 
      'Sports Complex',
      'Medical Center',
      'Wi-Fi Campus'
    ],
    admissions: {
      entrance: 'JEE Advanced',
      cutoff: 'Top Ranks',
      applicationDeadline: 'June 15, 2024'
    },
    contact: {
      email: 'info@iitd.ac.in',
      phone: '+91-11-26597000'
    },
    description: 'One of India\'s premier technological institutions, known for excellence in engineering and research.',
    images: [
      'https://images.unsplash.com/photo-1562774053-701939374585?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=600&fit=crop'
    ]
  },
  {
    id: 'aiims-delhi',
    name: 'All India Institute of Medical Sciences',
    shortName: 'AIIMS Delhi', 
    location: 'New Delhi, Delhi',
    ranking: 1,
    logo: 'https://upload.wikimedia.org/wikipedia/en/b/bb/All_India_Institute_of_Medical_Sciences%2C_New_Delhi_logo.png',
    tuitionFee: '₹1,00,000',
    collegeFee: '₹25,000', 
    hostelFee: '₹50,000',
    totalFee: '₹1,75,000',
    courses: [
      'Medicine',
      'Surgery', 
      'Nursing',
      'Medical Research',
      'Allied Health Sciences'
    ],
    rating: 4.9,
    reviewCount: 850,
    website: 'https://www.aiims.edu',
    established: 1956,
    type: 'Government',
    accreditation: 'NAAC A++',
    campusSize: '200 acres',
    studentCount: 5000,
    facultyCount: 800,
    placementRate: '100%',
    averagePackage: '₹20,00,000',
    facilities: [
      'Hospital',
      'Research Labs',
      'Library', 
      'Sports Complex',
      'Medical Museum'
    ],
    admissions: {
      entrance: 'NEET',
      cutoff: 'Top Ranks', 
      applicationDeadline: 'May 15, 2024'
    },
    contact: {
      email: 'info@aiims.edu',
      phone: '+91-11-26588500'
    },
    description: 'Premier medical institution of India with world-class healthcare and medical education.',
    images: [
      'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=600&fit=crop'
    ]
  }
];

async function addMockData() {
  try {
    console.log('🚀 Adding mock college data to Firestore...');
    
    for (const college of mockColleges) {
      const { id, ...collegeData } = college;
      await db.collection('colleges').doc(id).set(collegeData);
      console.log(`✅ Added college: ${college.name}`);
    }
    
    console.log('🎉 Successfully added all mock college data!');
    console.log('📱 Now hot reload your Flutter app to see the data');
    
  } catch (error) {
    console.error('❌ Error adding mock data:', error);
  }
}

addMockData();
