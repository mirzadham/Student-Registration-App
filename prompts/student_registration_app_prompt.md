# Student Registration App - Development Prompt

## Project Overview
As a senior full stack developer. Build a **Student Registration Mobile Application** using **Flutter** for the frontend with **MVVM architecture**, **Google Cloud Functions** for the backend, and **Firestore** as the database. The application must implement robust security through **Firebase Authentication (token-based)** and **AES-256 encryption** for sensitive data fields.

---

## Technical Requirements

### 1. Architecture: MVVM (Model-View-ViewModel)
- **Models**: Define data classes for `Student`, `Course`, `Registration`, etc.
- **ViewModels**: Business logic layer managing state and data transformations
- **Views**: UI components that observe ViewModel state changes
- **Repository Pattern**: Abstract data sources (API, local cache) from ViewModels
- **Dependency Injection**: Use `Provider` or `GetIt` for service injection

### 2. Backend: Firebase Cloud Functions (via Firebase CLI)
**Important**: All Cloud Functions will be developed locally using **Firebase CLI** with TypeScript. Use `firebase emulators:start` for local testing before deployment.

Create the following API endpoints:
- `POST /register` - Register a new student
- `GET /students/{id}` - Get student details
- `PUT /students/{id}` - Update student information
- `GET /courses` - List available courses
- `POST /enroll` - Enroll student in a course
- `GET /students/{id}/enrollments` - Get student's course enrollments
- `DELETE /enrollments/{id}` - Drop a course
- `GET /health` - Health check endpoint

### 3. Database: Firestore
Design collections:
- `students` - Student profiles (name, email, encrypted IC/passport number, phone, address)
- `courses` - Available courses (code, name, credits, capacity)
- `enrollments` - Student-course mappings with timestamps
- `academic_records` - Grades and academic history (encrypted GPA, grades)

### 4. Security Layer 1: Firebase Authentication
- Implement **Anonymous Authentication** for initial app access
- Implement **Email/Password Authentication** for student accounts
- Generate and validate **Firebase ID Tokens** for all API requests
- Create `validateToken` middleware to protect all Cloud Function endpoints
- Handle token refresh and session management
- Implement proper logout and session invalidation

### 5. Security Layer 2: AES-256 Encryption
Encrypt the following sensitive fields before storing in Firestore:
- IC Number / Passport Number
- Phone Number
- Home Address
- Emergency Contact Details
- Academic Records (GPA, grades)

Implementation requirements:
- Use AES-256-CBC encryption
- Store encryption key securely (not in source code)
- Encrypt on client-side before sending to backend
- Decrypt on client-side after receiving from backend
- Backend should only see encrypted data (zero-knowledge)

---

## Project Structure

```
student_registration_app/
├── lib/                                    # Flutter App
│   ├── core/
│   │   ├── constants/
│   │   ├── utils/
│   │   │   ├── encryption_helper.dart      # AES encryption/decryption
│   │   │   └── validators.dart
│   │   └── errors/
│   ├── data/
│   │   ├── models/
│   │   │   ├── student_model.dart
│   │   │   ├── course_model.dart
│   │   │   └── enrollment_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── student_repository.dart
│   │   │   └── course_repository.dart
│   │   └── services/
│   │       ├── api_service.dart
│   │       └── secure_storage_service.dart
│   ├── presentation/
│   │   ├── viewmodels/
│   │   │   ├── auth_viewmodel.dart
│   │   │   ├── registration_viewmodel.dart
│   │   │   └── enrollment_viewmodel.dart
│   │   ├── views/
│   │   │   ├── login_screen.dart
│   │   │   ├── registration_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── course_list_screen.dart
│   │   │   └── profile_screen.dart
│   │   └── widgets/
│   └── main.dart
├── functions/                               # Firebase Cloud Functions
│   ├── src/
│   │   ├── index.ts                        # Main entry point
│   │   ├── middleware/
│   │   │   └── auth.ts                     # Token validation middleware
│   │   ├── routes/
│   │   │   ├── students.ts                 # Student endpoints
│   │   │   ├── courses.ts                  # Course endpoints
│   │   │   └── enrollments.ts              # Enrollment endpoints
│   │   └── utils/
│   │       └── firestore.ts                # Firestore helpers
│   ├── package.json
│   ├── tsconfig.json
│   └── .env                                # Environment variables (gitignored)
├── firebase.json
├── firestore.rules
└── .firebaserc
```

### Firebase CLI Commands
```bash
# Initialize Firebase in project
firebase init functions

# Start local emulators for testing
firebase emulators:start --only functions,firestore,auth

# Deploy functions to production
firebase deploy --only functions

# View function logs
firebase functions:log
```

### Cloud Functions Configuration
- **Runtime**: Node.js 22 with TypeScript
- **Framework**: Express.js wrapped in Firebase Functions
- **Authentication**: Firebase Admin SDK for token validation
- **Database**: Firestore via Admin SDK
- **Environment**: Use `.env` for secrets (gitignored)

---

## Key Features to Implement

### Student Features
1. **Registration**: New student account creation with encrypted personal data
2. **Login/Logout**: Secure authentication with token management
3. **Profile Management**: View and update personal information
4. **Course Browsing**: View available courses with details
5. **Course Enrollment**: Enroll in courses with capacity validation
6. **My Enrollments**: View enrolled courses and status
7. **Drop Course**: Withdraw from enrolled courses

### Admin Features (Optional)
1. Course management (CRUD)
2. Student management and verification
3. Enrollment reports

---

## Security Checklist
- [ ] Firebase Authentication configured and tested
- [ ] Token validation middleware on all protected endpoints
- [ ] AES-256 encryption implemented for sensitive fields
- [ ] Encryption key stored securely (not hardcoded)
- [ ] HTTPS enforced for all API communications
- [ ] Input validation on both client and server
- [ ] Firestore security rules configured
- [ ] Error messages don't expose sensitive information

---

## Deliverables
1. Fully functional Flutter mobile app with MVVM architecture
2. Google Cloud Functions backend with all specified endpoints
3. Firestore database with proper schema and security rules
4. End-to-end encryption for sensitive data fields
5. Token-based authentication flow
6. Clean, documented, and maintainable code

---

## Development Approach
1. **Phase 1**: Set up project structure, Firebase configuration, and authentication
2. **Phase 2**: Implement encryption utilities and secure storage
3. **Phase 3**: Build Cloud Functions backend with Firestore integration
4. **Phase 4**: Develop Flutter frontend with MVVM pattern
5. **Phase 5**: Integration testing and security validation
