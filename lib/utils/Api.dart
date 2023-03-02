class API {
  static const String BASE_URL = "https://lmsbackend-production.up.railway.app/api/v1";
  /// USER SIGNIN URLS
  static const String TEACHER_SIGNIN_URL = "$BASE_URL/teacher/signin";
  static const String STUDENT_SIGNIN_URL = "$BASE_URL/student/signin";
  static const String PARENT_SIGNIN_URL = "$BASE_URL/parent/signin";

  /// UPDATE USER PROFILE URLS  
  static String TEACHER_UPDATE_PROFILE_URL(String teacher_id) => "$BASE_URL/teacher/$teacher_id";
  static String STUDENT_UPDATE_PROFILE_URL(String student_id) => "$BASE_URL/student/$student_id";
  static String PARENT_UPDATE_PROFILE_URL(String parent_id) => "$BASE_URL/parent/$parent_id";

  /// GET SUBJECTS LIST OF TEACHER URL
  static String SUBJECT_LIST_TEACHER_URL(String teacher_id) => "$BASE_URL/subjects/teacher/$teacher_id";
  
}