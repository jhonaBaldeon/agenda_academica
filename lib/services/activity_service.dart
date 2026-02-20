import 'package:cloud_firestore/cloud_firestore.dart';
// REVISA ESTA IMPORTACIÓN:
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ActivityModel>> getActivitiesStream(String courseId) {
    return _db
        .collection('activities')
        .where('course_id', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Pasamos doc.data() y el doc.id para que el modelo tenga el ID de Firestore
            return ActivityModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Método para que el docente cree una actividad
  Future<void> createActivity(ActivityModel activity) async {
    await _db.collection('activities').add(activity.toJson());
  }
}
