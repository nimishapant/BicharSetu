import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';
import '../model/comment_model.dart';
import '../model/post_model.dart';
import '../model/user_model.dart';

class AuthService {
  AuthService._internal();

  factory AuthService() => _instance;

  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _primaryBucket =
      'bicharsetu1.firebasestorage.app';
  static const String _legacyBucket = 'bicharsetu1.appspot.com';

  FirebaseStorage _storageForBucket(String bucket) {
    return FirebaseStorage.instanceFor(
      app: Firebase.app(),
      bucket: bucket,
    );
  }

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user uid
  String? get currentUid => _auth.currentUser?.uid;

  // Register with email, password, and username
  Future<UserModel> signUpWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    if (usernameQuery.docs.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'username-already-in-use',
        message: 'The username is already taken by another account.',
      );
    }

    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Could not complete registration. Please try again.',
      );
    }

    final UserModel userModel = UserModel(
      uid: user.uid,
      username: username.trim(),
      email: email.trim(),
      aboutMe: 'Write something about yourself...',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
  }

  Future<UserCredential> signInWithEmailOrUsername({
    required String emailOrUsername,
    required String password,
  }) async {
    String email = emailOrUsername.trim();

    if (!email.contains('@')) {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: email)
          .limit(1)
          .get();

      if (usernameQuery.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found with this username.',
        );
      }

      email = usernameQuery.docs.first.get('email') as String;
    }

    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) {
      final fallbackModel = UserModel(
        uid: user.uid,
        username: user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(fallbackModel.toMap());
      return fallbackModel;
    }

    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<UserModel?> get currentUserModelStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> updateUserProfile({
    required String username,
    required String email,
    required String aboutMe,
    String? profession,
    String? location,
    String? birthday,
    String? website,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .get();

    for (final doc in usernameQuery.docs) {
      if (doc.id != user.uid) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'The username is already taken by another account.',
        );
      }
    }

    await _firestore.collection('users').doc(user.uid).update({
      'username': username.trim(),
      'email': email.trim(),
      'aboutMe': aboutMe.trim(),
      if (profession != null) 'profession': profession.trim(),
      if (location != null) 'location': location.trim(),
      if (birthday != null) 'birthday': birthday.trim(),
      if (website != null) 'website': website.trim(),
    });

    if (user.email != email.trim()) {
      try {
        await user.verifyBeforeUpdateEmail(email.trim());
      } catch (_) {}
    }
  }

  Future<String> uploadProfilePhoto({required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Image file not found. Please pick the image again.');
    }
    final bytes = await file.readAsBytes();
    return _uploadImage(
      bytes: bytes,
      storageFolder: 'profile_photos',
      fileName: 'profile.jpg',
      firestoreField: 'profilePhoto',
    );
  }

  Future<String> uploadProfilePhotoFromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    return _uploadImage(
      bytes: bytes,
      storageFolder: 'profile_photos',
      fileName: 'profile.jpg',
      firestoreField: 'profilePhoto',
    );
  }

  Future<String> uploadCoverPhoto({required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Image file not found. Please pick the image again.');
    }
    final bytes = await file.readAsBytes();
    return _uploadImage(
      bytes: bytes,
      storageFolder: 'cover_photos',
      fileName: 'cover.jpg',
      firestoreField: 'coverPhoto',
    );
  }

  Future<String> uploadCoverPhotoFromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    return _uploadImage(
      bytes: bytes,
      storageFolder: 'cover_photos',
      fileName: 'cover.jpg',
      firestoreField: 'coverPhoto',
    );
  }

  Future<String> uploadGalleryPhotoFromXFile(XFile file) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await _uploadImage(
      bytes: bytes,
      storageFolder: 'gallery_photos',
      fileName: fileName,
      firestoreField: '',
      skipFirestoreUpdate: true,
    );

    await _firestore.collection('users').doc(user.uid).update({
      'galleryPhotos': FieldValue.arrayUnion([url]),
    });
    return url;
  }

  Future<String> _uploadImage({
    required Uint8List bytes,
    required String storageFolder,
    required String fileName,
    required String firestoreField,
    bool skipFirestoreUpdate = false,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final configuredBucket =
        DefaultFirebaseOptions.currentPlatform.storageBucket ?? _primaryBucket;

    final bucketsToTry = <String>{
      configuredBucket,
      _primaryBucket,
      _legacyBucket,
    }.toList();

    FirebaseException? lastError;

    for (final bucket in bucketsToTry) {
      try {
        final storage = _storageForBucket(bucket);
        final ref = storage
            .ref()
            .child(storageFolder)
            .child(user.uid)
            .child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
        );

        final snapshot = await ref.putData(bytes, metadata);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        if (!skipFirestoreUpdate && firestoreField.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).set(
            {firestoreField: downloadUrl},
            SetOptions(merge: true),
          );
        }

        return downloadUrl;
      } on FirebaseException catch (e) {
        lastError = e;
        final retryable = e.code == 'object-not-found' ||
            e.code == 'bucket-not-found' ||
            e.code == 'not-found';
        if (!retryable) rethrow;
      }
    }

    throw FirebaseException(
      plugin: 'firebase_storage',
      code: lastError?.code ?? 'upload-failed',
      message: _friendlyStorageMessage(lastError),
    );
  }

  String _friendlyStorageMessage(FirebaseException? error) {
    if (error?.code == 'unauthorized' || error?.code == 'permission-denied') {
      return 'Storage permission denied. Update Firebase Storage rules to allow authenticated uploads.';
    }
    if (error?.code == 'object-not-found' || error?.code == 'bucket-not-found') {
      return 'Firebase Storage bucket is not set up. Open Firebase Console → Storage → Get started, then try again.';
    }
    return error?.message ??
        'Could not upload image. Please check Firebase Storage setup.';
  }

  // ─────────────────────────────────────────────────────────
  //  Posts — CRUD
  // ─────────────────────────────────────────────────────────

  /// Create a new post in the 'posts' collection and increment user postCount.
  Future<void> createPost(PostModel post) async {
    final batch = _firestore.batch();
    final postDoc = _firestore.collection('posts').doc(post.postId);
    batch.set(postDoc, post.toMap());
    final userDoc = _firestore.collection('users').doc(post.uid);
    batch.update(userDoc, {'postCount': FieldValue.increment(1)});
    await batch.commit();
  }

  /// Stream of all posts ordered by creation time (newest first).
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data());
      }).toList();
    });
  }

  /// Toggle like for the current user on a post.
  Future<void> toggleLike(String postId) async {
    final uid = currentUid;
    if (uid == null) return;

    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final likes = List<String>.from(doc.data()?['likes'] ?? []);

    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await docRef.update({'likes': likes});
  }

  /// Delete a post (only if the current user is the author).
  Future<void> deletePost(String postId) async {
    final uid = currentUid;
    if (uid == null) return;

    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    if (doc.data()?['uid'] == uid) {
      await docRef.delete();
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Google Sign-In
  // ─────────────────────────────────────────────────────────

  /// Authenticate user via Google Sign-In and initialize Firestore profile.
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
    
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-aborted',
        message: 'Google Sign-In was cancelled by the user.',
      );
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final rawUsername = user.displayName?.replaceAll(' ', '').toLowerCase() ?? 'user';
        final finalUsername = rawUsername.isNotEmpty ? rawUsername : 'user';
        
        // Ensure username is unique in database
        final uniqueUsername = await _generateUniqueUsername(finalUsername);

        final userModel = UserModel(
          uid: user.uid,
          username: uniqueUsername,
          email: user.email ?? '',
          aboutMe: 'Write something about yourself...',
          profilePhoto: user.photoURL ?? '',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }
    }

    return userCredential;
  }

  Future<String> _generateUniqueUsername(String base) async {
    String candidate = base;
    int counter = 1;
    while (true) {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: candidate)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return candidate;
      candidate = '$base$counter';
      counter++;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  User Profiles & Streams
  // ─────────────────────────────────────────────────────────

  /// Get real-time stream of a specific user's model.
  Stream<UserModel?> userModelStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────────────────
  //  Follow / Unfollow System
  // ─────────────────────────────────────────────────────────

  /// Toggles follow state between the current user and a target user.
  Future<void> toggleFollowUser(String targetUid) async {
    final myUid = currentUid;
    if (myUid == null || myUid == targetUid) return;

    final myDocRef = _firestore.collection('users').doc(myUid);
    final targetDocRef = _firestore.collection('users').doc(targetUid);

    final myDoc = await myDocRef.get();
    if (!myDoc.exists) return;

    final followingList = List<String>.from(myDoc.data()?['following'] ?? []);
    if (followingList.contains(targetUid)) {
      // Unfollow
      await myDocRef.update({
        'following': FieldValue.arrayRemove([targetUid]),
      });
      await targetDocRef.update({
        'followers': FieldValue.arrayRemove([myUid]),
      });
    } else {
      // Follow
      await myDocRef.update({
        'following': FieldValue.arrayUnion([targetUid]),
      });
      await targetDocRef.update({
        'followers': FieldValue.arrayUnion([myUid]),
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  //  User specific posts
  // ─────────────────────────────────────────────────────────

  /// Stream of posts created by a specific user.
  Stream<List<PostModel>> getUserPostsStream(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data());
      }).toList();
      // Sort in memory because orderBy requires an index which may not exist yet
      posts.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return posts;
    });
  }

  /// Stream of posts liked by a specific user.
  Stream<List<PostModel>> getUserLikedPostsStream(String uid) {
    return _firestore
        .collection('posts')
        .where('likes', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data());
      }).toList();
      posts.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return posts;
    });
  }

  // ─────────────────────────────────────────────────────────
  //  Comments
  // ─────────────────────────────────────────────────────────

  /// Add a comment to a post and increment the post's commentCount.
  Future<void> addComment(CommentModel comment) async {
    final batch = _firestore.batch();

    // Write the comment document into the subcollection
    final commentDoc = _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.commentId);
    batch.set(commentDoc, comment.toMap());

    // Increment commentCount on the parent post
    final postDoc = _firestore.collection('posts').doc(comment.postId);
    batch.update(postDoc, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// Delete a comment and decrement the post's commentCount.
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final batch = _firestore.batch();

    final commentDoc = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    batch.delete(commentDoc);

    final postDoc = _firestore.collection('posts').doc(postId);
    batch.update(postDoc, {'commentCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  /// Real-time stream of comments for a post, ordered oldest first.
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList());
  }

  // ─────────────────────────────────────────────────────────
  //  Share / Repost count
  // ─────────────────────────────────────────────────────────

  /// Increment the shareCount on a post when the user shares it.
  Future<void> incrementShareCount(String postId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .update({'shareCount': FieldValue.increment(1)});
  }

  // ─────────────────────────────────────────────────────────
  //  User post count (real-time)
  // ─────────────────────────────────────────────────────────

  /// Stream of a user's post count.
  Stream<int> getUserPostCountStream(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
