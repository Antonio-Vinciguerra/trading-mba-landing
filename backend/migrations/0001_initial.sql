CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  country TEXT,
  preferred_language TEXT NOT NULL DEFAULT 'en',
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('owner','coach','student')),
  marketing_consent_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  last_login_at TEXT
);

CREATE TABLE IF NOT EXISTS enrollments (
  user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  programme_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','active','paused','cancelled','completed')),
  start_date TEXT,
  target_end_date TEXT,
  entitlement TEXT NOT NULL DEFAULT 'none' CHECK (entitlement IN ('none','campus','full_programme')),
  payment_method TEXT CHECK (payment_method IN ('bank_transfer','stripe')),
  payment_verified_at TEXT,
  payment_reference TEXT,
  verified_by TEXT,
  stripe_customer_id TEXT,
  classroom_course_id TEXT,
  drive_folder_id TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES users(id),
  coach_id TEXT NOT NULL REFERENCES users(id),
  calendar_event_id TEXT,
  meet_space_id TEXT,
  starts_at TEXT NOT NULL,
  ends_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','consent_required','captured','completed','cancelled')),
  agenda TEXT,
  consent_required INTEGER NOT NULL DEFAULT 1,
  consent_captured_at TEXT,
  recording_file_id TEXT,
  transcript_file_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS homework (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES users(id),
  module_id TEXT NOT NULL,
  title TEXT NOT NULL,
  instructions TEXT NOT NULL,
  due_at TEXT,
  status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned','in_progress','submitted','reviewed','complete')),
  submission_file_id TEXT,
  coach_feedback TEXT,
  completed_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS recaps (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES users(id),
  session_id TEXT NOT NULL REFERENCES sessions(id),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','in_review','approved','sent','withdrawn')),
  source_transcript_id TEXT,
  structured_draft TEXT,
  coach_edits TEXT,
  sent_at TEXT,
  student_visible_at TEXT,
  retention_until TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS consents (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  type TEXT NOT NULL CHECK (type IN ('terms','privacy','marketing','recording','transcription','ai_recap','testimonial')),
  version TEXT NOT NULL,
  granted INTEGER NOT NULL,
  granted_at TEXT,
  withdrawn_at TEXT,
  source TEXT,
  ip_hash TEXT,
  UNIQUE(user_id, type, version)
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  actor_id TEXT NOT NULL,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  metadata TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_homework_student ON homework(student_id, due_at);
CREATE INDEX IF NOT EXISTS idx_sessions_student ON sessions(student_id, starts_at);
CREATE INDEX IF NOT EXISTS idx_recaps_student ON recaps(student_id, student_visible_at);
CREATE INDEX IF NOT EXISTS idx_audit_actor ON audit_logs(actor_id, created_at);
