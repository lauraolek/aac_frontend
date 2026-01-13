class AppStrings {
  // Child Profile Management
  static const String addChildProfile = 'Lisa lapse profiil';
  static const String newChildName = 'Uue lapse nimi';
  static const String enterChildName = 'Lisa lapse nimi';
  static const String addChildButton = 'Lisa laps';
  static const String deleteChildProfile = 'Kustuta lapse profiil';
  static const String childProfiles = 'Laste profiilid';
  static const String activeChild = 'Valitud laps';
  static const String noActiveChild = 'Ühtki lapse profiili pole valitud';
  static String deleteChildConfirmation(String name) => 'Kas tahad kindlasti lapse "${name}" profiili kustutada?';

  // Category Options
  static const String editCategory = 'Muuda kategooriat';
  static const String deleteCategory = 'Kustuta kategooria';
  static const String addCategory = 'Lisa kategooria';
  static const String enterCategoryName = 'Sisesta kategooria nimi';
  static const String categoryName = 'Kategooria nimi';
  static String deleteCategoryConfirmation(String name) { return 'Kas tahad kustutada kategooria "${name}"'; }

  // Image options
  static const String pickImage = 'Kliki pildi valimiseks';
  static const String removeImage = 'Eemalda pilt';

  // Item Options
  static const String itemWord = 'Ese';
  static const String editItem = 'Muuda eset';
  static const String deleteItem = 'Kustuta ese';
  static const String addItem = 'Lisa ese';
  static const String newItemWord = 'Uus eseme nimi';
  static const String enterItemWord = 'Sisesta eseme nimi';
  static const String addItemButton = 'Lisa ese';
  static String deleteItemConfirmation(String word) {return 'Kas tahad kustutada eseme "${word}"';}

  // Image/Camera related strings
  static const String selectImageSource = 'Vali pildi allikas';
  static const String gallery = 'Galerii';
  static const String camera = 'Kaamera';
  static const String pickImageOrCapture = 'Vali pilt või tee foto';

  // Buttons
  static const String addButton = 'Lisa';
  static const String undoButton = 'Võta tagasi';
  static const String clearAllButton = 'Kustuta kõik';
  static const String speakButton = 'Räägi';
  static const String cancelButton = 'Loobu';
  static const String deleteButton = 'Kustuta';

  // Dialogs
  static const String clearAllItemsDialogTitle = 'Kustuta kõik?';
  static const String clearAllItemsDialogContent = 'Kas oled kindel, et tahad kõik kustutada?';

  // User Login/Auth
  static const String loggedInAs = 'Sisselogitud kui';
  static const String notLoggedIn = 'Pole sisse logitud';
  static const String loginTitle = 'Logi sisse';
  static const String registerTitle = 'Registreeri konto';
  static const String welcomeBack = 'Tere tulemast tagasi!';
  static const String createAccount = 'Loo konto';
  static const String email = 'Email';
  static const String password = 'Salasõna';
  static const String loginButton = 'Logi sisse';
  static const String registerButton = 'Registreeri';
  static const String pleaseEnterValidEmail = 'Palun sisesta kehtiv email';
  static const String passwordTooShort = 'Salasõna peab olema vähemalt 12 sümbolit pikk.';
  static const String createAccountPrompt = 'Pole kontot? Registreeri';
  static const String alreadyHaveAccountPrompt = 'Juba on konto? Logi sisse';
  static const String authError = 'Autentimise viga';
  static const String loggedInSuccessfully = 'Õnnestunud sisselogimine!';
  static const String registeredSuccessfully = 'Õnnestunud registreerimine! Palun logi sisse.';
  static const String loggedOutSuccessfully = 'Õnnestunud väljalogimine.';

  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String imageUrl = 'http://127.0.0.1:8000/api/v1/images/';
  static const String appTitle = 'AAC';
}