-- ========================================
-- COMPLETE DATA SETUP FOR ATTENDANCE APP
-- ========================================

-- 1. CEK DATA YANG SUDAH ADA
SELECT 'Checking existing data...' as step;

SELECT COUNT(*) as total_dosen FROM dosen;
SELECT COUNT(*) as total_matakuliah FROM matakuliah;
SELECT COUNT(*) as total_kelas FROM kelas;
SELECT COUNT(*) as total_kelas_dosen FROM kelas_dosen;

-- 2. INSERT MATA KULIAH (jika belum ada)
INSERT INTO matakuliah (id_matakuliah, kode_mk, nama_matakuliah, sks, semester, nip_dosen) VALUES
(1, 'IF301', 'Pemrograman Web', 3, 'Ganjil', '198501012010121001'),
(2, 'IF302', 'Basis Data', 3, 'Ganjil', '198601012011012001'),
(3, 'IF501', 'Kecerdasan Buatan', 3, 'Ganjil', '198701012012011001')
ON DUPLICATE KEY UPDATE kode_mk = kode_mk;

SELECT 'Mata kuliah inserted/updated' as step;

-- 3. INSERT KELAS (PENTING!)
INSERT INTO kelas (id_kelas, nama_kelas, id_matakuliah, tahun_ajaran, semester, ruangan, hari, jam_mulai, jam_selesai) VALUES
(1, 'TIF-3A', 1, '2024/2025', 'Ganjil', 'Lab Komputer 1', 'Senin', '08:00:00', '10:30:00'),
(2, 'TIF-3B', 2, '2024/2025', 'Ganjil', 'Lab Komputer 2', 'Selasa', '10:30:00', '13:00:00'),
(3, 'TIF-5A', 3, '2024/2025', 'Ganjil', 'Ruang 301', 'Rabu', '13:00:00', '15:30:00')
ON DUPLICATE KEY UPDATE nama_kelas = nama_kelas;

SELECT 'Kelas inserted/updated' as step;

-- 4. INSERT KELAS_DOSEN (Assignment)
INSERT INTO kelas_dosen (id_kelas, nip_dosen, tahun_ajaran, semester) VALUES
-- Dr. Ahmad Hidayat mengajar TIF-3A
(1, '198501012010121001', '2024/2025', 'Ganjil'),

-- Dr. Siti Nurhaliza mengajar TIF-3B  
(2, '198601012011012001', '2024/2025', 'Ganjil'),

-- Prof. Budi Santoso mengajar TIF-5A
(3, '198701012012011001', '2024/2025', 'Ganjil')
ON DUPLICATE KEY UPDATE tahun_ajaran = tahun_ajaran;

SELECT 'Kelas-Dosen assignments inserted' as step;

-- 5. VERIFIKASI HASIL
SELECT '=== VERIFICATION ===' as step;

-- Cek kelas
SELECT * FROM kelas ORDER BY id_kelas;

-- Cek assignment dosen ke kelas
SELECT 
    kd.id_kelas_dosen,
    d.nip,
    d.nama as nama_dosen,
    k.nama_kelas,
    mk.nama_matakuliah,
    kd.tahun_ajaran,
    kd.semester
FROM kelas_dosen kd
JOIN dosen d ON kd.nip_dosen = d.nip
JOIN kelas k ON kd.id_kelas = k.id_kelas
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
ORDER BY d.nama;

-- Test query seperti backend (untuk dosen1 - Dr. Ahmad)
SELECT 
    k.*, 
    mk.nama_matakuliah, 
    mk.kode_mk, 
    kd.tahun_ajaran, 
    kd.semester
FROM kelas_dosen kd
JOIN kelas k ON kd.id_kelas = k.id_kelas
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE kd.nip_dosen = '198501012010121001'
ORDER BY k.nama_kelas;

SELECT 'Setup complete!' as step;
