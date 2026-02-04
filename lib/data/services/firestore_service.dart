import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._(); 
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

 

  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }

  Future<List<Map<String, dynamic>>> getStudentsByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final snap = await _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snap.docs
        .map((d) => {
              'id': d.id,
              ...d.data(),
            })
        .toList();
  }

 

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTeacherClasses({
    required String teacherUid,
  }) {
    return _db
        .collection('classes')
        .where('teacherAuthUid', isEqualTo: teacherUid)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getClassDoc(String classId) async {
    final doc = await _db.collection('classes').doc(classId).get();
    if (!doc.exists) return null;
    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }


  String attendanceId(String classId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${classId}_$y-$m-$d';
  }

  Future<void> submitAttendance({
    required String schoolId,
    required String classId,
    required String studentAuthUid,
    required String recordedByUid,
    required String recordedByRole, 
    required bool isPresent,
    required DateTime date,

     
  }) async {
    final attendanceId = '${classId}_${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final docId = attendanceId;

    await _db
        .collection('attendance')
        .doc(docId)
        .collection('records')
        .doc(studentAuthUid)
        .set({
      'schoolId': schoolId,
      'classId': classId,
      'studentAuthUid': studentAuthUid,
      'status': isPresent ? 'present' : 'absent',
      'recordedAt': Timestamp.now(),
      'recordedByAuthUid': recordedByUid,
      'recordedByRole': recordedByRole,
      'dateKey':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> studentAbsenceStream(
    String studentUid,
  ) {
    return _db
        .collectionGroup('records')
        .where('studentAuthUid', isEqualTo: studentUid)
        .where('status', isEqualTo: 'absent')
        .orderBy('dateKey', descending: true)
        .snapshots();
  }


  Future<void> addAssignment({
    required String classId,
    required String title,
    required String description,
    required String teacherUid,
  }) async {
    await _db.collection('assignments').add({
      'classId': classId,
      'title': title,
      'description': description,
      'teacherAuthUid': teacherUid,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> classAssignmentsStream(
    String classId,
  ) {
    return _db
        .collection('assignments')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  

  Future<void> pushNotification({
    required String userUid,
    required String title,
    required String body,
  }) async {
    await _db.collection('notifications').add({
      'userAuthUid': userUid,
      'title': title,
      'body': body,
      'createdAt': Timestamp.now(),
      'read': false,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream(
    String uid,
  ) {
    return _db
        .collection('notifications')
        .where('userAuthUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> assignmentsByClassStream(
    String classId,
  ) {
    return _db
        .collection('assignments')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  Future<void> pushAbsenceNotifications({
  required List<String> absentStudentIds,
  required DateTime date,
}) async {
  final batch = _db.batch();

  for (final studentUid in absentStudentIds) {
    final docRef = _db.collection('notifications').doc();

    batch.set(docRef, {
      'studentAuthUid': studentUid,
      'type': 'absence',
      'title': 'Absence Recorded',
      'message': 'You were marked absent on '
          '${date.year}-${date.month}-${date.day}',
      'date': Timestamp.fromDate(date),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
}

Future<List<Map<String, dynamic>>> getTeacherClasses(String teacherUid) async {
  final snap = await _db
      .collection('classes')
      .where('authUid', isEqualTo: teacherUid)
      .get();

  return snap.docs.map((d) {
    return {
      'id': d.id,
      ...d.data(),
    };
  }).toList();
}

}

