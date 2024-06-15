// ------ CONSTANTS --------
const createUserTable = '''CREATE TABLE IF NOT EXISTS $userTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $emailColumn TEXT NOT NULL UNIQUE
  );''';

const createSignalTable = '''CREATE TABLE IF NOT EXISTS $signalTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $userIdColumn INTEGER NOT NULL,
    $nameColumn TEXT,
    $startTimeColumn DATETIME NOT NULL,
    $stopTimeColumn DATETIME NOT NULL,
    $createdAtColumn DATETIME DEFAULT CURRENT_TIMESTAMP,
    $signalTypeColumn TEXT NOT NULL,
    FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
);''';

const createECGTable = '''CREATE TABLE IF NOT EXISTS $ecgTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $signalIdColumn INTEGER NOT NULL,
    ecg BLOB NOT NULL,
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
    FOREIGN KEY ($signalIdColumn) REFERENCES $signalTable ($idColumn)
);''';

// ------ CONSTANTS --------
const dbName = 'cardio.db';
const signalTable = 'cardio_signal';
const userTable = 'cardio_user';
const ecgTable = 'cardio_ecg';
const bpTable = 'cardio_bp';
const btempTable = 'cardio_btemp';

const idColumn = 'id';
const nameColumn = 'signal_name';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const startTimeColumn = 'start_time';
const stopTimeColumn = 'stop_time';
const signalTypeColumn = 'signal_type';
const signalIdColumn = 'signal_id';

const createdAtColumn = 'created_at';

// signal types
const ecgType = 'ECG';
const bpType = 'BP';
const btempType = 'BTEMP';
