class AppStrings {
  // Profile Management
  static const String addProfile = 'Lisa profiil';
  static const String newProfileName = 'Uue profiili nimi';
  static const String enterProfileName = 'Lisa nimi';
  static const String addProfileButton = 'Lisa profiil';
  static const String deleteProfile = 'Kustuta profiil';
  static const String profiles = 'Profiilid';
  static const String activeProfile = 'Valitud profiil';
  static const String noActiveProfile = 'Ühtki profiili pole valitud';
  static String deleteProfileConfirmation(String name) => 'Kas tahad kindlasti profiili "${name}" kustutada?';

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
  static const String confirmButton = 'Kinnita';
  static const String okButton = 'OK';

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
  static const String forgotPassword = 'Unustasid parooli?';  
  static const String passwordResetTitle = 'Kiri saadetud';
  static const String passwordResetContent = 'Kui selle e-mailiga konto on olemas, saadame sulle parooli lähtestamise lingi.';
  static const String passwordResetError = 'Parooli lähtestamise palve ebaõnnestus.';

  // Child Mode / PIN Dialog
  static const String settings = 'Seaded';
  static const String childMode = 'Lapserežiim';
  static const String childModeDescription = 'Lukustab seaded ja muutmise';
  static const String exitChildModeTitle = 'Välju lapserežiimist';
  static const String enterPinPrompt = 'Sisesta PIN-kood:';
  static const String pinHint = '****';
  static const String wrongPinError = 'Vale PIN-kood. Proovi uuesti.';
  static const String childModeActive = 'Lapserežiim on aktiivne';
  static const String changePin = 'Muuda PIN-koodi';
  static const String oldPinWrong = 'Vana PIN on vale';
  static const String enterNewPin = 'Sisesta uus PIN-kood';
  static const String pinMustBeFourDigits = 'PIN peab olema 4 numbrit';
  static const String pinMismatch = 'PIN-koodid ei ühti. Proovi uuesti.';
  static const String enterPinAgain = 'Sisesta PIN uuesti';
  static const String confirmNewPin = 'Kinnita uus PIN-kood';
  static const String setupPin = 'Seadista PIN-kood';
  static const String forgotPin = 'Unustasin PIN-koodi';
  static const String pinResetSent = 'Uus PIN on saadetud teie e-mailile.';
  static const String pinResetFailed = 'E-maili saatmine ebaõnnestus. Proovi uuesti.';

  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String imageUrl = 'http://127.0.0.1:8000/api/v1/images/';
  static const String appTitle = 'AAC';
}