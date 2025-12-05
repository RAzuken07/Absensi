-- Test & Insert Sample Data for Kelas

-- 1. Check if table exists
SHOW TABLES LIKE 'kelas';

-- 2. Check current data
SELECT * FROM kelas;

-- 3. If empty, insert sample data
INSERT INTO kelas (nama_kelas, id_matakuliah, tahun_ajaran, semester, ruangan, hari, jam_mulai, jam_selesai) VALUES
('TIF-3A', 1, '2024/2025', 'Ganjil', 'Lab Komputer 1', 'Senin', '08:00:00', '10:30:00'),
('TIF-3B', 2, '2024/2025', 'Ganjil', 'Lab Komputer 2', 'Selasa', '10:30:00', '13:00:00'),
('TIF-5A', 3, '2024/2025', 'Ganjil', 'Ruang 301', 'Rabu', '13:00:00', '15:30:00')
ON DUPLICATE KEY UPDATE nama_kelas = nama_kelas;

-- 4. Verify data exists
SELECT COUNT(*) as total_kelas FROM kelas;

-- 5. Check with join (like backend query)
SELECT k.*, mk.nama_matakuliah, mk.kode_mk 
FROM kelas k
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
ORDER BY k.nama_kelas;
