-- Migration: Add schedule columns to kelas_dosen table
-- Run this if table kelas_dosen doesn't have these columns yet

ALTER TABLE kelas_dosen 
ADD COLUMN IF NOT EXISTS ruangan VARCHAR(50),
ADD COLUMN IF NOT EXISTS hari VARCHAR(20),
ADD COLUMN IF NOT EXISTS jam_mulai TIME,
ADD COLUMN IF NOT EXISTS jam_selesai TIME;

-- Verify
DESCRIBE kelas_dosen;
