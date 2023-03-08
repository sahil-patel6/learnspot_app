class API {
  // static const String BASE_URL = "https://learnspot-api.up.railway.app/api/v1";
  static const String BASE_URL = "http://192.168.1.7:8000/api/v1";
  /// USER SIGN-IN URLS
  static String USER_SIGNIN_URL(String type_of_user) => "$BASE_URL/$type_of_user/signin";

  /// UPDATE USER PROFILE URLS  
  static String USER_UPDATE_PROFILE_URL(String user_id,String type_of_user) => "$BASE_URL/$type_of_user/$user_id";

  /// GET USER PROFILE URLS
  static String GET_USER_PROFILE_URL(String user_id,String type_of_user) => "$BASE_URL/$type_of_user/$user_id";

  /// GET LIST OF SUBJECTS
  static String SUBJECT_LIST_TEACHER_URL(String teacher_id) => "$BASE_URL/subjects/teacher/$teacher_id";
  static String GET_LIST_OF_SUBJECTS_BY_SEMESTER(String semester_id,String user_id,String type_of_user) => "$BASE_URL/subjects/$semester_id/$type_of_user/$user_id";
  static String GET_LIST_OF_SUBJECTS_BY_STUDENT(String student_id) => "$BASE_URL/subjects/student/$student_id";

  /// RESOURCES
  static String GET_RESOURCES(String subject_id,String user_id,String type_of_user) => "$BASE_URL/resources/$subject_id/$type_of_user/$user_id";
  static String CREATE_RESOURCE(String teacher_id) => "$BASE_URL/resource/create/teacher/$teacher_id";
  static String UPDATE_RESOURCE(String resource_id,String teacher_id) => "$BASE_URL/resource/$resource_id/teacher/$teacher_id";
  static String DELETE_RESOURCE(String resource_id,String teacher_id) => "$BASE_URL/resource/$resource_id/teacher/$teacher_id";

  /// ASSIGNMENTS
  static String GET_ASSIGNMENTS(String subject_id,String user_id,String type_of_user) => "$BASE_URL/assignments/$subject_id/$type_of_user/$user_id";
  static String CREATE_ASSIGNMENT(String teacher_id) => "$BASE_URL/assignment/create/teacher/$teacher_id";
  static String UPDATE_ASSIGNMENT(String assignment_id,String teacher_id) => "$BASE_URL/assignment/$assignment_id/teacher/$teacher_id";
  static String DELETE_ASSIGNMENT(String assignment_id,String teacher_id) => "$BASE_URL/assignment/$assignment_id/teacher/$teacher_id";

  /// NOTICES
  static String GET_NOTICES(String semester_id,String user_id,String type_of_user) => "$BASE_URL/notices/semester/$semester_id/$type_of_user/$user_id";
  static String CREATE_NOTICE(String teacher_id) => "$BASE_URL/notice/create/teacher/$teacher_id";
  static String UPDATE_NOTICE(String notice_id,String teacher_id) => "$BASE_URL/notice/$notice_id/teacher/$teacher_id";
  static String DELETE_NOTICE(String notice_id,String teacher_id) => "$BASE_URL/notice/$notice_id/teacher/$teacher_id";

}