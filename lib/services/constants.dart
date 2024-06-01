// ------ CONSTANTS --------
const createUserTable = '''CREATE TABLE IF NOT EXISTS cardio_user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE
  );''';

const createSignalTable = '''CREATE TABLE IF NOT EXISTS cardio_signal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    stop_time DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    signal_type TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES cardio_user (id)
);''';

const createECGTable = '''CREATE TABLE IF NOT EXISTS cardio_ecg (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_id INTEGER NOT NULL,
    ecg BLOB NOT NULL,
    FOREIGN KEY (signal_id) REFERENCES cardio_signal (id)
);''';

const createBPTable = '''CREATE TABLE IF NOT EXISTS cardio_bp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_id INTEGER NOT NULL,
    bp_systolic INTEGER NOT NULL,
    bp_diastolic INTEGER NOT NULL,
    FOREIGN KEY (signal_id) REFERENCES cardio_signal (id)
);''';

const createBTempTable = '''CREATE TABLE IF NOT EXISTS cardio_btemp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_id INTEGER NOT NULL,
    body_temp REAL NOT NULL,
    FOREIGN KEY (signal_id) REFERENCES cardio_signal (id)
);''';

// ------ CONSTANTS --------
const dbName = 'cardio.db';
const userTable = 'cardio_user';
const ecgTable = 'cardio_ecg';
const bpTable = 'cardio_bp';
const btempTable = 'cardio_btemp';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const startTimeColumn = 'start_time';
const stopTimeColumn = 'stop_time';
const signalTypeColumn = 'signal_type';
