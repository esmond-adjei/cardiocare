const createUserTable = '''CREATE TABLE IF NOT EXISTS $userTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $emailColumn TEXT NOT NULL UNIQUE
  );''';

const createMedicalInfoTable = '''CREATE TABLE $medicalInfoTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $infoType TEXT,
    $infoValue TEXT,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
  );''';

const createSignalTable = '''CREATE TABLE IF NOT EXISTS $signalTable (
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

const createECGTable = '''CREATE TABLE IF NOT EXISTS $ecgTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    ecg BLOB NOT NULL,
    hrv REAL,
    hbpm INTEGER,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const createBPTable = '''CREATE TABLE IF NOT EXISTS $bpTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    bp_systolic INTEGER NOT NULL,
    bp_diastolic INTEGER NOT NULL,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const createBTempTable = '''CREATE TABLE IF NOT EXISTS $btempTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    body_temp REAL NOT NULL,
    body_temp_min REAL,
    body_temp_max REAL,
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

const createChatHistoryTable = '''CREATE TABLE $chatHistoryTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER,
    $messageColumn TEXT,
    $timestampColumn TEXT,
    $isFromUserColumn INTEGER,
    $statusColumn INTEGER,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
);''';

// ------ CONSTANTS --------
const idColumn = 'id';
const dbName = 'cardio.db';

// user app
const userTable = 'cardio_user';
const medicalInfoTable = 'medical_info';
const infoType = 'info_type';
const infoValue = 'info_value';

const userIdColumn = 'user_id';
const emailColumn = 'email';

// signal app
const signalTable = 'cardio_signal';
const ecgTable = 'cardio_ecg';
const bpTable = 'cardio_bp';
const btempTable = 'cardio_btemp';

// signal types
const ecgType = 'ECG';
const bpType = 'BP';
const btempType = 'BTEMP';

const nameColumn = 'signal_name';
const startTimeColumn = 'start_time';
const stopTimeColumn = 'stop_time';
const signalTypeColumn = 'signal_type';
const signalIdColumn = 'signal_id';
const signalInfoColumn = 'signal_info';
const createdAtColumn = 'created_at';

// chatbot app
const chatHistoryTable = 'chat_history';
const messageColumn = 'message';
const timestampColumn = 'timestamp';
const isFromUserColumn = 'is_from_user';
const statusColumn = 'status';
