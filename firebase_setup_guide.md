# Firebase Setup Guide for Hitagyana College Finder

## Step 1: Create Collection in Firebase Console

1. Go to your Firebase Console: https://console.firebase.google.com/
2. Select your project: `hitagyana-clg-finder`
3. Go to **Firestore Database**
4. Click **"Start collection"**
5. Collection ID: `colleges`

## Step 2: Add Sample College Documents

### College 1: IIT Delhi

**Document ID:** `iit-delhi` (or auto-generate)

```json
{
  "name": "Indian Institute of Technology Delhi",
  "shortName": "IIT Delhi",
  "location": "New Delhi, Delhi",
  "ranking": 2,
  "logo": "https://upload.wikimedia.org/wikipedia/en/f/fd/Indian_Institute_of_Technology_Delhi_Logo.svg",
  "tuitionFee": "₹2,50,000",
  "collegeFee": "₹50,000",
  "hostelFee": "₹75,000",
  "totalFee": "₹3,75,000",
  "courses": [
    "Computer Science & Engineering",
    "Mechanical Engineering", 
    "Electrical Engineering",
    "Civil Engineering",
    "Chemical Engineering"
  ],
  "rating": 4.8,
  "reviewCount": 1250,
  "website": "https://www.iitd.ac.in",
  "established": 1961,
  "type": "Government",
  "accreditation": "NAAC A++",
  "campusSize": "320 acres",
  "studentCount": 8500,
  "facultyCount": 450,
  "placementRate": "95%",
  "averagePackage": "₹18,00,000",
  "facilities": [
    "Library",
    "Hostels", 
    "Sports Complex",
    "Medical Center",
    "Wi-Fi Campus"
  ],
  "admissions": {
    "entrance": "JEE Advanced",
    "cutoff": "Top Ranks",
    "applicationDeadline": "June 15, 2024"
  },
  "contact": {
    "email": "info@iitd.ac.in",
    "phone": "+91-11-26597000"
  },
  "description": "One of India's premier technological institutions, known for excellence in engineering and research.",
  "images": [
    "https://images.unsplash.com/photo-1562774053-701939374585?w=800&h=600&fit=crop",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=600&fit=crop"
  ]
}
```

### College 2: AIIMS Delhi

**Document ID:** `aiims-delhi` (or auto-generate)

```json
{
  "name": "All India Institute of Medical Sciences",
  "shortName": "AIIMS Delhi", 
  "location": "New Delhi, Delhi",
  "ranking": 1,
  "logo": "https://upload.wikimedia.org/wikipedia/en/b/bb/All_India_Institute_of_Medical_Sciences%2C_New_Delhi_logo.png",
  "tuitionFee": "₹1,00,000",
  "collegeFee": "₹25,000", 
  "hostelFee": "₹50,000",
  "totalFee": "₹1,75,000",
  "courses": [
    "Medicine",
    "Surgery", 
    "Nursing",
    "Medical Research",
    "Allied Health Sciences"
  ],
  "rating": 4.9,
  "reviewCount": 850,
  "website": "https://www.aiims.edu",
  "established": 1956,
  "type": "Government",
  "accreditation": "NAAC A++",
  "campusSize": "200 acres",
  "studentCount": 5000,
  "facultyCount": 800,
  "placementRate": "100%",
  "averagePackage": "₹20,00,000",
  "facilities": [
    "Hospital",
    "Research Labs",
    "Library", 
    "Sports Complex",
    "Medical Museum"
  ],
  "admissions": {
    "entrance": "NEET",
    "cutoff": "Top Ranks", 
    "applicationDeadline": "May 15, 2024"
  },
  "contact": {
    "email": "info@aiims.edu",
    "phone": "+91-11-26588500"
  },
  "description": "Premier medical institution of India with world-class healthcare and medical education.",
  "images": [
    "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=600&fit=crop",
    "https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=600&fit=crop"
  ]
}
```

### College 3: IIM Ahmedabad

**Document ID:** `iim-ahmedabad` (or auto-generate)

```json
{
  "name": "Indian Institute of Management Ahmedabad",
  "shortName": "IIM Ahmedabad",
  "location": "Ahmedabad, Gujarat", 
  "ranking": 1,
  "logo": "https://upload.wikimedia.org/wikipedia/en/1/1c/Indian_Institute_of_Management_Ahmedabad_Logo.svg",
  "tuitionFee": "₹25,00,000",
  "collegeFee": "₹2,00,000",
  "hostelFee": "₹1,50,000", 
  "totalFee": "₹28,50,000",
  "courses": [
    "MBA",
    "Management",
    "Post Graduate Programme",
    "Executive Education", 
    "PhD Management"
  ],
  "rating": 4.8,
  "reviewCount": 950,
  "website": "https://www.iima.ac.in",
  "established": 1961,
  "type": "Government",
  "accreditation": "AACSB",
  "campusSize": "110 acres",
  "studentCount": 1200,
  "facultyCount": 150,
  "placementRate": "100%",
  "averagePackage": "₹35,00,000",
  "facilities": [
    "Library", 
    "Case Study Rooms",
    "Sports Complex",
    "Auditorium",
    "Computer Center"
  ],
  "admissions": {
    "entrance": "CAT",
    "cutoff": "Top Ranks",
    "applicationDeadline": "November 30, 2024"
  },
  "contact": {
    "email": "info@iima.ac.in", 
    "phone": "+91-79-6632-4658"
  },
  "description": "India's premier management institute known for excellence in management education and research.",
  "images": [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop",
    "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop"
  ]
}
```

## Step 3: How to Add in Firebase Console

1. **Create Collection:**
   - Click "Start collection" 
   - Enter `colleges` as collection ID
   - Click "Next"

2. **Add Document:**
   - You can auto-generate Document ID or use custom ones like `iit-delhi`
   - Click "Next"

3. **Add Fields:**
   - For each field, select the appropriate type:
     - **String:** name, shortName, location, logo, tuitionFee, etc.
     - **Number:** ranking, established, studentCount, etc.
     - **Array:** courses, facilities, images
     - **Map:** admissions, contact
   - Copy the values from the JSON above

4. **Save Document**

## Step 4: App Configuration

The app is already configured to:
- ✅ Connect to your Firebase project
- ✅ Read from "colleges" collection  
- ✅ Handle all field types properly
- ✅ Search and filter functionality
- ✅ Category-based filtering (Engineering, Medical, Management)

## Important Field Requirements

**Required Fields for App to Work:**
- `name` (String)
- `shortName` (String) 
- `location` (String)
- `ranking` (Number)
- `courses` (Array of Strings)
- `totalFee` (String)
- `rating` (Number)
- `type` (String)

**Optional but Recommended:**
- `logo` (String - URL)
- `description` (String)
- `website` (String)
- `contact` (Map with email/phone)
- `admissions` (Map with entrance/cutoff)
- `facilities` (Array of Strings)
- `images` (Array of String URLs)

## Testing

After adding the documents:
1. Run the app: `flutter run`
2. The colleges should appear on the main screen
3. Test search functionality
4. Test category filters (Engineering, Medical, Management)
5. Swipe navigation should be disabled
6. Category chips should respond immediately

Your app will automatically fetch and display this data! 