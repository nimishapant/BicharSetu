import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  /// Create a new post in the 'posts' collection.
  Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').doc(post.postId).set(post.toMap());
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
  //  User profiles & follow
  // ─────────────────────────────────────────────────────────

  Stream<UserModel?> userModelStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> toggleFollowUser(String targetUid) async {
    final myUid = currentUid;
    if (myUid == null || myUid == targetUid) return;

    final myDocRef = _firestore.collection('users').doc(myUid);
    final targetDocRef = _firestore.collection('users').doc(targetUid);

    final myDoc = await myDocRef.get();
    if (!myDoc.exists) return;

    final followingList = List<String>.from(myDoc.data()?['following'] ?? []);
    if (followingList.contains(targetUid)) {
      await myDocRef.update({
        'following': FieldValue.arrayRemove([targetUid]),
      });
      await targetDocRef.update({
        'followers': FieldValue.arrayRemove([myUid]),
      });
    } else {
      await myDocRef.update({
        'following': FieldValue.arrayUnion([targetUid]),
      });
      await targetDocRef.update({
        'followers': FieldValue.arrayUnion([myUid]),
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Comments
  // ─────────────────────────────────────────────────────────

  Future<void> addComment(CommentModel comment) async {
    final batch = _firestore.batch();

    final commentDoc = _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.commentId);
    batch.set(commentDoc, comment.toMap());

    final postDoc = _firestore.collection('posts').doc(comment.postId);
    batch.update(postDoc, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> addReply(CommentModel reply) async {
    assert(reply.parentId.isNotEmpty, 'Replies must have a parentId');

    final batch = _firestore.batch();

    final replyDoc = _firestore
        .collection('posts')
        .doc(reply.postId)
        .collection('comments')
        .doc(reply.parentId)
        .collection('replies')
        .doc(reply.commentId);
    batch.set(replyDoc, reply.toMap());

    final parentDoc = _firestore
        .collection('posts')
        .doc(reply.postId)
        .collection('comments')
        .doc(reply.parentId);
    batch.update(parentDoc, {'replyCount': FieldValue.increment(1)});

    await batch.commit();
  }

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

  Future<void> deleteReply({
    required String postId,
    required String parentCommentId,
    required String replyId,
  }) async {
    final batch = _firestore.batch();

    final replyDoc = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(parentCommentId)
        .collection('replies')
        .doc(replyId);
    batch.delete(replyDoc);

    final parentDoc = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(parentCommentId);
    batch.update(parentDoc, {'replyCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromMap(d.data())).toList());
  }

  Stream<List<CommentModel>> getRepliesStream(
    String postId,
    String parentCommentId,
  ) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(parentCommentId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromMap(d.data())).toList());
  }

  Future<void> toggleCommentReaction({
    required String postId,
    required String commentId,
    required String reactionType,
    String parentCommentId = '',
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    final DocumentReference docRef = parentCommentId.isEmpty
        ? _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
        : _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(parentCommentId)
            .collection('replies')
            .doc(commentId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>?;
    final raw = data?['reactions'] as Map<String, dynamic>? ?? {};
    final reactions =
        raw.map((k, v) => MapEntry(k, List<String>.from(v as List)));

    for (final key in reactions.keys.toList()) {
      reactions[key]?.remove(uid);
      if (reactions[key]?.isEmpty ?? false) reactions.remove(key);
    }

    final hadIt = raw[reactionType] != null &&
        (raw[reactionType] as List).contains(uid);
    if (!hadIt) {
      reactions[reactionType] = [...(reactions[reactionType] ?? []), uid];
    }

    await docRef.update({'reactions': reactions});
  }

  Future<String> uploadCommentImage(File file) async {
    if (!await file.exists()) {
      throw Exception('Image file not found. Please pick the image again.');
    }
    final bytes = await file.readAsBytes();
    return _uploadImage(
      bytes: bytes,
      storageFolder: 'comment_images',
      fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      firestoreField: '',
      skipFirestoreUpdate: true,
    );
  }
}
