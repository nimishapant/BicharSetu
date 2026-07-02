import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';

import '../model/account_status_model.dart';
import '../model/comment_model.dart';
import '../model/diary_entry_model.dart';
import '../model/notification_model.dart';
import '../model/post_model.dart';
import '../model/user_model.dart';

class AuthService {
  AuthService._internal();

  factory AuthService() => _instance;

  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cloudinary unsigned upload — no API key needed
  static const String _cloudinaryCloudName = 'dvwqyliow';
  static const String _cloudinaryUploadPreset = 'bichar_setu_preset';
  static const String _cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload';



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

    // Initialize Account Status
    final initialStatus = AccountStatusModel.initial(user.uid);
    await _firestore.collection('account_status').doc(user.uid).set(initialStatus.toMap());

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
      
      // Initialize Account Status
      final initialStatus = AccountStatusModel.initial(user.uid);
      await _firestore.collection('account_status').doc(user.uid).set(initialStatus.toMap());

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
    return _uploadFile(
      file: file,
      storageFolder: 'profile_photos',
      firestoreField: 'profilePhoto',
    );
  }

  Future<String> uploadProfilePhotoFromXFile(XFile xfile) async {
    return _uploadFile(
      file: File(xfile.path),
      storageFolder: 'profile_photos',
      firestoreField: 'profilePhoto',
    );
  }

  Future<String> uploadCoverPhoto({required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Image file not found. Please pick the image again.');
    }
    return _uploadFile(
      file: file,
      storageFolder: 'cover_photos',
      firestoreField: 'coverPhoto',
    );
  }

  Future<String> uploadCoverPhotoFromXFile(XFile xfile) async {
    return _uploadFile(
      file: File(xfile.path),
      storageFolder: 'cover_photos',
      firestoreField: 'coverPhoto',
    );
  }

  Future<String> uploadGalleryPhotoFromXFile(XFile xfile) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final url = await _uploadFile(
      file: File(xfile.path),
      storageFolder: 'gallery_photos',
      firestoreField: '',
      skipFirestoreUpdate: true,
    );

    await _firestore.collection('users').doc(user.uid).update({
      'galleryPhotos': FieldValue.arrayUnion([url]),
    });
    return url;
  }

  /// Core upload — plain HTTP multipart POST to Cloudinary unsigned endpoint.
  /// No API key required — uses the unsigned upload preset.
  Future<String> _uploadFile({
    required File file,
    required String storageFolder,
    required String firestoreField,
    bool skipFirestoreUpdate = false,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    try {
      // Unique public_id per upload so every upload gets a new URL.
      // Firestore saves the new URL → Flutter loads the fresh image.
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'bichar_setu/$storageFolder/${user.uid}_$timestamp';

      final uri = Uri.parse(_cloudinaryUploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = publicId
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode != 200) {
        final decoded = json.decode(responseBody) as Map<String, dynamic>;
        final msg = decoded['error']?['message'] ?? responseBody;
        throw Exception('Cloudinary upload failed (${ streamedResponse.statusCode}): $msg');
      }

      final decoded = json.decode(responseBody) as Map<String, dynamic>;
      final downloadUrl = decoded['secure_url'] as String?;
      if (downloadUrl == null) {
        throw Exception('Cloudinary response missing secure_url');
      }

      if (!skipFirestoreUpdate && firestoreField.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).set(
          {firestoreField: downloadUrl},
          SetOptions(merge: true),
        );
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Toggle private/public account for the current user.
  Future<void> setPrivateAccount({required bool isPrivate}) async {
    final uid = currentUid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'isPrivate': isPrivate});
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

    // Notify @mentioned users in the post body/title — best effort
    try {
      final fullText = '${post.title} ${post.body}';
      await _sendMentionNotifications(
        text: fullText,
        senderUid: post.uid,
        senderUsername: post.username,
        senderProfilePhoto: post.profilePhoto,
        postId: post.postId,
        contextId: post.postId,
      );
    } catch (_) {}
  }

  /// Stream of all posts ordered by creation time (newest first).
  /// Posts by private accounts are excluded unless the current user follows them.
  Stream<List<PostModel>> getPostsStream() {
    final myUid = currentUid;

    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Build a set of private account UIDs that the current user does NOT follow
      final Set<String> privateBlockedUids = {};

      if (myUid != null) {
        // Get current user's following list once
        final myDoc = await _firestore.collection('users').doc(myUid).get();
        final following =
            List<String>.from(myDoc.data()?['following'] ?? []);

        // Collect unique author UIDs from this batch
        final authorUids =
            snapshot.docs.map((d) => d.data()['uid'] as String? ?? '').toSet();

        // For each author we don't follow, check if they're private
        for (final uid in authorUids) {
          if (uid == myUid || following.contains(uid)) continue;
          final userDoc =
              await _firestore.collection('users').doc(uid).get();
          final isPrivate =
              (userDoc.data()?['isPrivate'] as bool?) ?? false;
          if (isPrivate) privateBlockedUids.add(uid);
        }
      }

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data()))
          .where((post) => !privateBlockedUids.contains(post.uid))
          .toList();
    });
  }

  /// Toggle like for the current user on a post, and notify the post author.
  Future<void> toggleLike(String postId) async {
    final uid = currentUid;
    if (uid == null) return;

    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final likes = List<String>.from(data['likes'] ?? []);
    final postAuthorUid = data['uid'] as String? ?? '';

    final isLiking = !likes.contains(uid);

    if (isLiking) {
      likes.add(uid);
    } else {
      likes.remove(uid);
    }

    await docRef.update({'likes': likes});

    // Send notification only when liking (not unliking) and not self-like
    if (isLiking && postAuthorUid.isNotEmpty && postAuthorUid != uid) {
      final me = await getCurrentUserModel();
      if (me == null) return;

      final postPreview = _buildPostPreview(data);
      await _sendNotification(
        NotificationModel(
          notificationId: '${postId}_like_$uid',
          recipientUid: postAuthorUid,
          senderUid: uid,
          senderUsername: me.username,
          senderProfilePhoto: me.profilePhoto,
          type: NotificationType.like,
          postId: postId,
          postPreview: postPreview,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  /// Delete a post (only if the current user is the author).
  Future<void> deletePost(String postId) async {
    final uid = currentUid;
    if (uid == null) return;

    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    if (doc.data()?['uid'] == uid) {
      // Also decrement the user's postCount
      final batch = _firestore.batch();
      batch.delete(docRef);
      batch.update(
        _firestore.collection('users').doc(uid),
        {'postCount': FieldValue.increment(-1)},
      );
      await batch.commit();
    }
  }

  /// Update a post's editable fields (only if current user is author
  /// and the post was created within the last 24 hours).
  Future<void> updatePost({
    required String postId,
    required String title,
    required String body,
    required List<String> keywords,
    required String category,
    required int backgroundIndex,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not signed in');

    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) throw Exception('Post not found');

    final data = doc.data()!;
    if (data['uid'] != uid) throw Exception('Not your post');

    // Enforce 24-hour edit window
    final createdAt = data['createdAt'];
    if (createdAt != null) {
      final created = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
      if (DateTime.now().difference(created).inHours >= 24) {
        throw Exception('Posts can only be edited within 24 hours of posting');
      }
    }

    await docRef.update({
      'title': title.trim(),
      'body': body.trim(),
      'keywords': keywords,
      'category': category,
      'backgroundIndex': backgroundIndex,
      'editedAt': FieldValue.serverTimestamp(),
    });
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

        // Initialize Account Status
        final initialStatus = AccountStatusModel.initial(user.uid);
        await _firestore.collection('account_status').doc(user.uid).set(initialStatus.toMap());
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

  /// Add a top-level comment and increment the post's commentCount.
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

    // Notify post author — best effort
    try {
      final postSnap =
          await _firestore.collection('posts').doc(comment.postId).get();
      if (!postSnap.exists) return;
      final postData = postSnap.data()!;
      final postAuthorUid = postData['uid'] as String? ?? '';

      if (postAuthorUid.isNotEmpty && postAuthorUid != comment.uid) {
        final postPreview = _buildPostPreview(postData);
        await _sendNotification(
          NotificationModel(
            notificationId: 'comment_${comment.commentId}',
            recipientUid: postAuthorUid,
            senderUid: comment.uid,
            senderUsername: comment.username,
            senderProfilePhoto: comment.profilePhoto,
            type: NotificationType.comment,
            postId: comment.postId,
            postPreview: postPreview,
            commentText: comment.text,
            createdAt: DateTime.now(),
          ),
        );
      }

      // Notify mentioned users in the comment text
      await _sendMentionNotifications(
        text: comment.text,
        senderUid: comment.uid,
        senderUsername: comment.username,
        senderProfilePhoto: comment.profilePhoto,
        postId: comment.postId,
        contextId: comment.commentId,
      );
    } catch (_) {}
  }

  /// Add a reply to an existing comment.
  /// The reply is stored as a subcollection under the parent comment.
  /// Also increments the parent comment's replyCount.
  Future<void> addReply(CommentModel reply) async {
    assert(reply.parentId.isNotEmpty, 'Replies must have a parentId');

    final batch = _firestore.batch();

    // Write reply under posts/{postId}/comments/{parentId}/replies/{replyId}
    final replyDoc = _firestore
        .collection('posts')
        .doc(reply.postId)
        .collection('comments')
        .doc(reply.parentId)
        .collection('replies')
        .doc(reply.commentId);
    batch.set(replyDoc, reply.toMap());

    // Increment replyCount on the parent comment
    final parentDoc = _firestore
        .collection('posts')
        .doc(reply.postId)
        .collection('comments')
        .doc(reply.parentId);
    batch.update(parentDoc, {'replyCount': FieldValue.increment(1)});

    await batch.commit();

    // Notify the parent comment author — best effort
    try {
      final parentSnap = await parentDoc.get();
      if (!parentSnap.exists) return;
      final parentAuthorUid = parentSnap.data()?['uid'] as String? ?? '';

      if (parentAuthorUid.isNotEmpty && parentAuthorUid != reply.uid) {
        await _sendNotification(
          NotificationModel(
            notificationId: 'reply_${reply.commentId}',
            recipientUid: parentAuthorUid,
            senderUid: reply.uid,
            senderUsername: reply.username,
            senderProfilePhoto: reply.profilePhoto,
            type: NotificationType.comment,
            postId: reply.postId,
            postPreview: 'replied to your comment',
            commentText: reply.text,
            createdAt: DateTime.now(),
          ),
        );
      }

      // Notify mentioned users in the reply text
      await _sendMentionNotifications(
        text: reply.text,
        senderUid: reply.uid,
        senderUsername: reply.username,
        senderProfilePhoto: reply.profilePhoto,
        postId: reply.postId,
        contextId: reply.commentId,
      );
    } catch (_) {}
  }

  /// Delete a top-level comment and decrement post's commentCount.
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

  /// Delete a reply and decrement parent's replyCount.
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

  /// Real-time stream of top-level comments for a post, oldest first.
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

  /// Real-time stream of replies for a specific comment, oldest first.
  Stream<List<CommentModel>> getRepliesStream(
      String postId, String parentCommentId) {
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

  // ─────────────────────────────────────────────────────────
  //  Comment Reactions
  // ─────────────────────────────────────────────────────────

  /// Toggle a reaction on a comment or a reply.
  /// [parentCommentId] is only set when reacting to a reply.
  Future<void> toggleCommentReaction({
    required String postId,
    required String commentId,
    required String reactionType,
    String parentCommentId = '',
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    // Resolve the correct document reference
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

  // ─────────────────────────────────────────────────────────
  //  Image uploads for comments and posts
  // ─────────────────────────────────────────────────────────

  /// Upload an image for a comment and return its Cloudinary URL.
  Future<String> uploadCommentImage(File file) async {
    return _uploadFile(
      file: file,
      storageFolder: 'comment_images',
      firestoreField: '',
      skipFirestoreUpdate: true,
    );
  }

  /// Upload an image for a post and return its Cloudinary URL.
  Future<String> uploadPostImage(File file) async {
    return _uploadFile(
      file: file,
      storageFolder: 'post_images',
      firestoreField: '',
      skipFirestoreUpdate: true,
    );
  }

  /// Toggle save/bookmark a post for the current user.
  Future<void> toggleSavePost(String postId) async {
    final uid = currentUid;
    if (uid == null) return;
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    final saved = List<String>.from(doc.data()?['savedPosts'] ?? []);
    if (saved.contains(postId)) {
      await docRef.update({'savedPosts': FieldValue.arrayRemove([postId])});
    } else {
      await docRef.update({'savedPosts': FieldValue.arrayUnion([postId])});
    }
  }

  /// Stream of posts saved/bookmarked by a specific user.
  Stream<List<PostModel>> getUserSavedPostsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((userSnap) async {
      final saved = List<String>.from(
          userSnap.data()?['savedPosts'] ?? []);
      if (saved.isEmpty) return <PostModel>[];
      final snaps = await Future.wait(
        saved.map((id) => _firestore.collection('posts').doc(id).get()),
      );
      return snaps
          .where((d) => d.exists)
          .map((d) => PostModel.fromMap(d.data()!))
          .toList();
    });
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

  // ─────────────────────────────────────────────────────────
  //  Account Status
  // ─────────────────────────────────────────────────────────

  Stream<AccountStatusModel?> getAccountStatusStream(String uid) {
    return _firestore
        .collection('account_status')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        // Create if missing (for legacy users)
        final initial = AccountStatusModel.initial(uid);
        await _firestore.collection('account_status').doc(uid).set(initial.toMap());
        return initial;
      }
      return AccountStatusModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateAccountStatus({
    required String uid,
    required AccountStanding standing,
    required String message,
    String? reason,
    String? actionType,
  }) async {
    final statusDoc = _firestore.collection('account_status').doc(uid);
    final snap = await statusDoc.get();
    
    int newWarningCount = 0;
    List<AccountAction> actions = [];
    
    if (snap.exists) {
      final current = AccountStatusModel.fromMap(snap.data()!);
      newWarningCount = current.warningCount + (standing == AccountStanding.warning ? 1 : 0);
      actions = current.actions;
    }

    if (reason != null && actionType != null) {
      actions.add(AccountAction(
        reason: reason,
        timestamp: DateTime.now(),
        type: actionType,
      ));
    }

    final newStatus = AccountStatusModel(
      uid: uid,
      standing: standing,
      warningCount: newWarningCount,
      message: message,
      actions: actions,
      updatedAt: DateTime.now(),
    );

    await statusDoc.set(newStatus.toMap());

    // Send notification
    await _sendNotification(
      NotificationModel(
        notificationId: 'account_status_${DateTime.now().millisecondsSinceEpoch}',
        recipientUid: uid,
        senderUid: 'system',
        senderUsername: 'BicharSetu',
        senderProfilePhoto: '',
        type: NotificationType.accountStatus,
        postId: '', // Not linked to a post
        postPreview: message,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Notifications
  // ─────────────────────────────────────────────────────────

  /// Internal: write a notification document.
  Future<void> _sendNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.notificationId)
        .set(notification.toMap());
  }

  /// Parse @mentions from [text], look up each username in Firestore,
  /// and send a mention notification to every matched user.
  /// Skips the sender themselves and deduplicates by username.
  Future<void> _sendMentionNotifications({
    required String text,
    required String senderUid,
    required String senderUsername,
    required String senderProfilePhoto,
    required String postId,
    required String contextId, // commentId or postId used to deduplicate
  }) async {
    final mentionRegex = RegExp(r'@(\w+)');
    final mentions = mentionRegex
        .allMatches(text)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet(); // unique usernames

    for (final username in mentions) {
      if (username == senderUsername.toLowerCase()) continue;

      try {
        final snap = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) continue;
        final recipientUid = snap.docs.first.id;
        if (recipientUid == senderUid) continue;

        await _sendNotification(
          NotificationModel(
            notificationId: 'mention_${contextId}_$recipientUid',
            recipientUid: recipientUid,
            senderUid: senderUid,
            senderUsername: senderUsername,
            senderProfilePhoto: senderProfilePhoto,
            type: NotificationType.mention,
            postId: postId,
            postPreview: text.length > 60 ? '${text.substring(0, 60)}…' : text,
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {
        // One failed mention should never block the others
      }
    }
  }

  /// Build a short post preview string from raw post data.
  String _buildPostPreview(Map<String, dynamic> data) {
    final title = (data['title'] as String?) ?? '';
    final body = (data['body'] as String?) ?? '';
    final text = title.isNotEmpty ? title : body;
    return text.length > 60 ? '${text.substring(0, 60)}…' : text;
  }

  /// Real-time stream of notifications for the current user, newest first.
  Stream<List<NotificationModel>> getNotificationsStream() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList());
  }

  /// Stream of the count of unread notifications for the current user.
  Stream<int> getUnreadNotificationCount() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Mark a single notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications for the current user as read.
  Future<void> markAllNotificationsRead() async {
    final uid = currentUid;
    if (uid == null) return;

    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────
  //  Diary
  // ─────────────────────────────────────────────────────────

  /// Create a new diary entry.
  Future<void> createDiaryEntry(DiaryEntryModel entry) async {
    await _firestore
        .collection('diary')
        .doc(entry.entryId)
        .set(entry.toMap());
  }

  /// Update an existing diary entry (owner only — enforced client-side).
  Future<void> updateDiaryEntry(DiaryEntryModel entry) async {
    await _firestore.collection('diary').doc(entry.entryId).update({
      'title':     entry.title,
      'body':      entry.body,
      'mood':      entry.mood.name,
      'isPublic':  entry.isPublic,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a diary entry (owner only).
  Future<void> deleteDiaryEntry(String entryId) async {
    final uid = currentUid;
    if (uid == null) return;
    final doc = await _firestore.collection('diary').doc(entryId).get();
    if (doc.exists && doc.data()?['uid'] == uid) {
      await _firestore.collection('diary').doc(entryId).delete();
    }
  }

  /// Stream of the current user's diary entries, newest first.
  /// Sorts in memory to avoid requiring a composite index.
  Stream<List<DiaryEntryModel>> getMyDiaryStream() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('diary')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final entries = snap.docs
              .map((d) => DiaryEntryModel.fromMap(d.data()))
              .toList();
          entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));
          return entries;
        });
  }

  /// Stream of the current user's entries for a specific date.
  /// Filters in memory to avoid multi-field composite index.
  Stream<List<DiaryEntryModel>> getDiaryEntriesForDate(DateTime date) {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    final day = DateTime(date.year, date.month, date.day);
    return _firestore
        .collection('diary')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((d) => DiaryEntryModel.fromMap(d.data()))
              .where((e) {
                final ed = DateTime(
                    e.entryDate.year, e.entryDate.month, e.entryDate.day);
                return ed == day;
              })
              .toList()
            ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
        });
  }

  /// Stream of public diary entries from all users, newest first.
  /// Sorts in memory to avoid composite index on isPublic + entryDate.
  Stream<List<DiaryEntryModel>> getPublicDiaryStream() {
    return _firestore
        .collection('diary')
        .where('isPublic', isEqualTo: true)
        .limit(50)
        .snapshots()
        .map((snap) {
          final entries = snap.docs
              .map((d) => DiaryEntryModel.fromMap(d.data()))
              .toList();
          entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));
          return entries;
        });
  }

  /// Compute the current streak (consecutive days with at least one entry).
  Future<int> getDiaryStreak() async {
    final uid = currentUid;
    if (uid == null) return 0;
    final snap = await _firestore
        .collection('diary')
        .where('uid', isEqualTo: uid)
        .limit(60)
        .get();

    if (snap.docs.isEmpty) return 0;

    final days = snap.docs
        .map((d) {
          final ts = d.data()['entryDate'];
          if (ts is Timestamp) return ts.toDate();
          return null;
        })
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    int streak = 0;
    DateTime cursor = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (final day in days) {
      if (day == cursor ||
          day == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = day;
      } else {
        break;
      }
    }
    return streak;
  }
}
