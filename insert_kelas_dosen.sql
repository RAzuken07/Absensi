-- Insert Sample Dosen-Kelas Assignments

-- Pastikan data dosen dan kelas sudah ada
SELECT * FROM dosen LIMIT 3;
SELECT * FROM kelas LIMIT 3;

-- Insert assignments: Dosen mengajar kelas tertentu
INSERT INTO kelas_dosen (id_kelas, nip_dosen, tahun_ajaran, semester) VALUES
-- Dr. Ahmad Hidayat mengajar TIF-3A (kelas id=1)
(1, '198501012010121001', '2024/2025', 'Ganjil'),

-- Dr. Siti Nurhaliza mengajar TIF-3B (kelas id=2)  
(2, '198601012011012001', '2024/2025', 'Ganjil'),

-- Prof. Budi Santoso mengajar TIF-5A (kelas id=3)
(3, '198701012012011001', '2024/2025', 'Ganjil');

-- Verifikasi data sudah masuk
SELECT 
    kd.id_kelas_dosen,
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

-- Test query untuk dosen tertentu (seperti backend)
SELECT k.*, mk.nama_matakuliah, mk.kode_mk, kd.tahun_ajaran, kd.semester
FROM kelas_dosen kd
JOIN kelas k ON kd.id_kelas = k.id_kelas
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE kd.nip_dosen = '198501012010121001'  -- Dr. Ahmad
ORDER BY k.nama_kelas;
