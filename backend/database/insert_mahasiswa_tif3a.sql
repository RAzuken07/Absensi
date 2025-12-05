-- Insert mahasiswa untuk kelas TIF-3A (id_kelas = 6)
-- Hapus data dummy jika ada
DELETE FROM mahasiswa WHERE id_kelas = 6;

-- Insert mahasiswa baru
INSERT INTO mahasiswa (nim, nama, email, password, id_kelas) VALUES
('2141720001', 'Ahmad Rizki', 'ahmad.rizki@student.pnl.ac.id', '$2b$10$dummyhashedpassword1', 6),
('2141720002', 'Siti Nur Azizah', 'siti.azizah@student.pnl.ac.id', '$2b$10$dummyhashedpassword2', 6),
('2141720003', 'Budi Santoso', 'budi.santoso@student.pnl.ac.id', '$2b$10$dummyhashedpassword3', 6),
('2141720004', 'Dewi Lestari', 'dewi.lestari@student.pnl.ac.id', '$2b$10$dummyhashedpassword4', 6),
('2141720005', 'Eko Prasetyo', 'eko.prasetyo@student.pnl.ac.id', '$2b$10$dummyhashedpassword5', 6),
('2141720006', 'Fitri Handayani', 'fitri.handayani@student.pnl.ac.id', '$2b$10$dummyhashedpassword6', 6),
('2141720007', 'Gilang Ramadhan', 'gilang.ramadhan@student.pnl.ac.id', '$2b$10$dummyhashedpassword7', 6),
('2141720008', 'Hana Putri', 'hana.putri@student.pnl.ac.id', '$2b$10$dummyhashedpassword8', 6),
('2141720009', 'Irfan Maulana', 'irfan.maulana@student.pnl.ac.id', '$2b$10$dummyhashedpassword9', 6),
('2141720010', 'Joko Widodo', 'joko.widodo@student.pnl.ac.id', '$2b$10$dummyhashedpassword10', 6),
('2141720011', 'Kartika Sari', 'kartika.sari@student.pnl.ac.id', '$2b$10$dummyhashedpassword11', 6),
('2141720012', 'Lukman Hakim', 'lukman.hakim@student.pnl.ac.id', '$2b$10$dummyhashedpassword12', 6),
('2141720013', 'Maya Anggraini', 'maya.anggraini@student.pnl.ac.id', '$2b$10$dummyhashedpassword13', 6),
('2141720014', 'Nanda Pratama', 'nanda.pratama@student.pnl.ac.id', '$2b$10$dummyhashedpassword14', 6),
('2141720015', 'Oki Setiawan', 'oki.setiawan@student.pnl.ac.id', '$2b$10$dummyhashedpassword15', 6),
('2141720016', 'Putri Maharani', 'putri.maharani@student.pnl.ac.id', '$2b$10$dummyhashedpassword16', 6),
('2141720017', 'Qori Rahman', 'qori.rahman@student.pnl.ac.id', '$2b$10$dummyhashedpassword17', 6),
('2141720018', 'Rina Wulandari', 'rina.wulandari@student.pnl.ac.id', '$2b$10$dummyhashedpassword18', 6),
('2141720019', 'Sandi Firmansyah', 'sandi.firmansyah@student.pnl.ac.id', '$2b$10$dummyhashedpassword19', 6),
('2141720020', 'Tia Rahmawati', 'tia.rahmawati@student.pnl.ac.id', '$2b$10$dummyhashedpassword20', 6);

-- Verify insert
SELECT COUNT(*) as total_mahasiswa FROM mahasiswa WHERE id_kelas = 6;
SELECT nim, nama FROM mahasiswa WHERE id_kelas = 6 ORDER BY nim;
