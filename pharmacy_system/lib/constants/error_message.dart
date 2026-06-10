class ErrorMessage {

  //login and signup errors
  static const String AUTH_ERROR = "Authentication failed. Please check your credentials.";
  static const String SIGNUP_ERROR = "Unable to sign up. Please try again.";
  static const String LOGIN_ERROR = "Invalid login credentials. Please try again.";
  static const String PASSWORD_NOT_STRONG_ERROR = "Password must contain at least 8 characters, uppercase, lowercase, number and special character.";
  static const String PASSWORDS_DO_NOT_MATCH_ERROR = "Passwords do not match. Please try again.";
  static const String EMAIL_ALREADY_IN_USE_ERROR = "This email is already in use. Please use a different email.";
  static const String INVALID_EMAIL_ERROR = "Invalid email format. Please enter a valid email address.";

  //prescription errors
  static const String LOAD_PRESCRIPTION_ERROR = "Unable to load the prescriptions.";
  static const String STORE_PRESCRIPTION_ERROR = "Unable to store the prescription.";
  static const String UPDATE_PRESCRIPTION_ERROR = "Unable to update the prescription.";
  static const String DELETE_PRESCRIPTION_ERROR = "Unable to delete the prescription.";

  //reminder errors
  static const String LOAD_REMINDER_ERROR = "Unable to load the reminders.";
  static const String STORE_REMINDER_ERROR = "Unable to store the reminder.";
  static const String UPDATE_REMINDER_ERROR = "Unable to update the reminder.";
  static const String DELETE_REMINDER_ERROR = "Unable to delete the reminder.";

  //pharmacist profile errors
  static const String LOAD_PROFILE_ERROR = "Unable to load the pharmacist profile.";
  static const String SAVE_PROFILE_ERROR = "Unable to save the pharmacist profile.";
  static const String UPDATE_PROFILE_ERROR = "Unable to update the pharmacist profile.";
  static const String DELETE_PROFILE_ERROR = "Unable to delete the pharmacist profile.";

  //chat errors
  static const String LOAD_CHAT_ERROR = "Unable to load the chat messages.";
  static const String SEND_MESSAGE_ERROR = "Unable to send the message.";
  static const String EDIT_MESSAGE_ERROR = "Unable to edit the message.";
  static const String DELETE_MESSAGE_ERROR = "Unable to delete the message.";
  static const String LISTEN_MESSAGES_ERROR = "Unable to listen to the messages.";

  //user profile errors
  static const String LOAD_USER_PROFILE_ERROR = "Unable to load the user profile.";
  static const String SAVE_USER_PROFILE_ERROR = "Unable to save the user profile.";
  static const String UPDATE_USER_PROFILE_ERROR = "Unable to update the user profile.";
  static const String DELETE_USER_PROFILE_ERROR = "Unable to delete the user profile.";
  
}