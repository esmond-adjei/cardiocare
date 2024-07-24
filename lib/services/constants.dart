// ------ USER APP --------
const String createUserTable = '''CREATE TABLE IF NOT EXISTS $userTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $emailColumn TEXT NOT NULL UNIQUE
  );''';

const String createUserProfileTable =
    '''CREATE TABLE IF NOT EXISTS $userProfileTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $profilePictureColumn TEXT,
    $firstNameColumn TEXT,
    $lastNameColumn TEXT,
    $dateOfBirthColumn TEXT,
    $sexColumn TEXT,
    $phoneNumberColumn TEXT,
    $addressColumn TEXT,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
  );''';

const String createMedicalInfoTable =
    '''CREATE TABLE IF NOT EXISTS $medicalInfoTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $noteColumn TEXT,
    $hasCvdColumn INTEGER,
    $diagnosedCvdColumn TEXT,
    $yearsOfSmokingColumn INTEGER,
    $heightColumn REAL,
    $weightColumn REAL,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
  );''';

const String createEmergencyContactTable =
    '''CREATE TABLE IF NOT EXISTS $emergencyContactTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $contactNameColumn TEXT,
    $contactPhoneNumberColumn TEXT,
    $contactEmailColumn TEXT,
    $relationshipColumn TEXT,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
  );''';

// ------ SIGNAL APP --------
const String createSignalTable = '''CREATE TABLE IF NOT EXISTS $signalTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER NOT NULL,
    $nameColumn TEXT,
    $startTimeColumn DATETIME NOT NULL,
    $stopTimeColumn DATETIME NOT NULL,
    $createdAtColumn DATETIME DEFAULT CURRENT_TIMESTAMP,
    $signalTypeColumn TEXT NOT NULL,
    $signalInfoColumn TEXT,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
);''';

const String createECGTable = '''CREATE TABLE IF NOT EXISTS $ecgTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    ecg BLOB NOT NULL,
    hrv REAL,
    hbpm INTEGER,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const String createBPTable = '''CREATE TABLE IF NOT EXISTS $bpTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    bp_systolic INTEGER NOT NULL,
    bp_diastolic INTEGER NOT NULL,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const String createBTempTable = '''CREATE TABLE IF NOT EXISTS $btempTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    body_temp REAL NOT NULL,
    body_temp_min REAL,
    body_temp_max REAL,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const String createChatHistoryTable = '''CREATE TABLE $chatHistoryTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $messageColumn TEXT,
    $timestampColumn TEXT,
    $isFromUserColumn INTEGER,
    $statusColumn INTEGER,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
);''';

// ------ CONSTANTS --------
const String idColumn = 'id';
const String dbName = 'cardio.db';

// user app
const String userTable = 'cardio_user';
const String userIdColumn = 'user_id';
const String emailColumn = 'email';

// user app: profile
const String userProfileTable = 'user_profiles';
const String profilePictureColumn = 'profile_picture_path';
const String firstNameColumn = 'first_name';
const String lastNameColumn = 'last_name';
const String dateOfBirthColumn = 'date_of_birth';
const String sexColumn = 'sex';
const String phoneNumberColumn = 'phone_number';
const String addressColumn = 'address';

// user app: medical info
const String medicalInfoTable = 'medical_info';
const String noteColumn = 'note';
const String hasCvdColumn = 'has_cvd';
const String diagnosedCvdColumn =
    'diagnosed_cvd'; // if hascvd, then what's the cvd?
const String yearsOfSmokingColumn = 'years_of_smoking';
const String heightColumn = 'height';
const String weightColumn = 'weight';

// user app: emergency contacts
const String emergencyContactTable = 'emergency_contacts';
const String contactNameColumn = 'name';
const String relationshipColumn = 'relationship';
const String contactEmailColumn = 'email';
const String contactPhoneNumberColumn = 'phone_number';

// signal app
const String signalTable = 'cardio_signal';
const String ecgTable = 'cardio_ecg';
const String bpTable = 'cardio_bp';
const String btempTable = 'cardio_btemp';

// signal types
const String ecgType = 'ECG';
const String bpType = 'BP';
const String btempType = 'BTEMP';

const String nameColumn = 'signal_name';
const String startTimeColumn = 'start_time';
const String stopTimeColumn = 'stop_time';
const String signalTypeColumn = 'signal_type';
const String signalIdColumn = 'signal_id';
const String signalInfoColumn = 'signal_info';
const String createdAtColumn = 'created_at';

// chatbot app
const String chatHistoryTable = 'chat_history';
const String messageColumn = 'message';
const String timestampColumn = 'timestamp';
const String isFromUserColumn = 'is_from_user';
const String statusColumn = 'status';
