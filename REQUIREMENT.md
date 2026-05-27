Build a production-quality Flutter application for Android and Web using Firebase as the backend.

Application Overview:
Create a dark-themed collaborative notes and file storage application similar to a lightweight Discord + Notion hybrid.

Platforms:

* Android
* Web

Backend:
Use only Firebase services:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Hosting

Core Requirements:

1. Authentication

* Users can register with:

  * username
  * password
* No email verification required
* Simple login flow
* Persist login session until midnight local time
* After midnight local time, force re-login
* If the same account logs out manually from one device, all active sessions on all devices should be invalidated
* Securely store authentication/session state
* Passwords must never be stored in plain text

2. Notes Module
   Features:

* Create note
* Edit note
* Delete note
* Realtime collaborative editing similar to Google Docs
* Multiple devices/users can see updates instantly
* Rich text support:

  * bold
  * italic
  * underline
  * headings
  * bullet lists
  * code block
* Markdown support if possible
* Notes should support:

  * title
  * content
  * created date
  * updated date
  * background color
  * background image
* Users can:

  * upload custom background image
  * choose from predefined backgrounds
* Notes should autosave in realtime
* Offline viewing support using Firestore offline persistence
* Each user should only see their own notes
* Search notes
* Sort notes by:

  * latest updated
  * created date
  * title
* Support pinned/favorite notes

3. File Upload Module
   Features:

* Upload any file type
* Max file size: 100MB
* Allow:

  * videos
  * apk
  * exe
  * zip
  * pdf
  * images
  * all document formats
* Store files in Firebase Storage
* Save metadata in Firestore
* Users can:

  * upload file
  * delete file
  * rename file
  * download file
* Files should appear in:

  * grid view
  * list view toggle
* Show:

  * file name
  * upload date
  * file size
  * file type icon
* Search and sort files
* Each user only sees their own uploaded files
* Offline viewing for metadata only

4. Realtime Sync

* Use Firestore realtime listeners
* Updates should instantly sync across:

  * web
  * android
  * multiple devices
* Handle simultaneous edits safely

5. UI/UX
   Theme:

* Discord-like dark theme
* Modern clean UI
* Smooth animations
* Responsive layout for web and mobile
* Material 3 design

Screens:

* Splash screen
* Login screen
* Registration screen
* Dashboard
* Notes tab
* Files tab
* Profile/settings screen

Navigation:

* Bottom navigation for mobile
* Sidebar navigation for web

6. Architecture
   Use clean scalable architecture.

Preferred stack:

* Riverpod for state management
* GoRouter for routing
* Freezed + JsonSerializable for models
* Repository pattern
* Clean architecture
* Feature-first folder structure

7. Firebase Requirements
   Configure:

* Firebase Auth
* Firestore
* Firebase Storage
* Firebase Hosting

Create:

* Firestore security rules
* Firebase Storage rules

Rules:

* Users can access only their own data/files

8. Session Management
   Implement custom session expiration:

* Session expires automatically at midnight local time
* Manual logout from one device invalidates all active sessions
* Use Firestore session tokens/versioning approach

9. Search & Filtering
   Implement:

* realtime search
* sorting
* filtering
* favorites/pinning

10. Performance

* Lazy loading
* Pagination
* File upload progress indicator
* Optimized Firestore queries
* Proper caching

11. Error Handling
    Implement:

* centralized error handling
* retry mechanism
* upload failure recovery
* offline handling
* user-friendly messages

12. Deliverables
    Generate:

* Complete Flutter project
* Firebase configuration
* Firestore rules
* Storage rules
* README.md
* Setup instructions
* Firebase Hosting deployment instructions
* Android APK build instructions

13. Code Quality
    Requirements:

* Null safety
* Strong typing
* Clean reusable widgets
* Proper comments
* Modular architecture
* Production-ready code

14. Suggested Packages
    Use suitable modern packages such as:

* flutter_riverpod
* go_router
* firebase_core
* firebase_auth
* cloud_firestore
* firebase_storage
* flutter_quill
* markdown
* hive or shared_preferences
* freezed
* json_serializable
* cached_network_image
* file_picker

15. Additional Requirements

* Responsive web layout
* Dark mode only
* Smooth realtime editing experience
* Loading skeletons/shimmer
* Drag-and-drop file upload for web
* Upload progress UI
* Keyboard shortcuts for web
* Avoid unnecessary rebuilds
* Follow Flutter best practices

16. Folder Structure
    Use scalable feature-first structure like:
    lib/
    core/
    features/
    auth/
    notes/
    files/
    dashboard/
    shared/
    services/
    routing/

17. Important
    Do not generate placeholder code.
    Generate fully working implementation-ready code with proper architecture and Firebase integration.
