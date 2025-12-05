-- SQL untuk assign mahasiswa ke kelas dan setup data test

-- 1. Pastikan mahasiswa punya id_kelas
-- Contoh: Update mahasiswa dengan NIM tertentu ke kelas tertentu
UPDATE mahasiswa
SET id_kelas = 1  -- Sesuaikan dengan ID kelas yang ada (misal kelas 3E)
WHERE nim = '2301010001';  -- Ganti dengan NIM mahasiswa yang login

-- 2. Cek data kelas yang tersedia
SELECT * FROM kelas;

-- 3. Cek mata kuliah yang ada
SELECT * FROM matakuliah;

-- 4. Pastikan ada relasi kelas_dosen (dosen mengampu mata kuliah di kelas)
-- Sample insert jika belum ada:
INSERT INTO kelas_dosen (id_kelas, nip, id_matakuliah)
VALUES 
  (1, '198901012015041001', 1),  -- Dosen 1 mengampu MK 1 di kelas 1
  (1, '198902022016052002', 2),  -- Dosen 2 mengampu MK 2 di kelas 1
  (1, '198903032017063003', 3);  -- Dosen 3 mengampu MK 3 di kelas 1

-- 5. Verify data untuk mahasiswa tertentu
SELECT 
    m.nim,
    m.nama,
    k.nama_kelas,
    mk.nama_mk,
    mk.kode_mk,
    mk.sks,
    d.nama as nama_dosen
FROM mahasiswa m
JOIN kelas k ON m.id_kelas = k.id_kelas
JOIN kelas_dosen kd ON k.id_kelas = kd.id_kelas
JOIN dosen d ON kd.nip = d.nip
JOIN matakuliah mk ON kd.id_matakuliah = mk.id_matakuliah
WHERE m.nim = '2301010001';  -- Ganti dengan NIM yang login
