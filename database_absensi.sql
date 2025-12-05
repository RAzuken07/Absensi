-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 23 Nov 2025 pada 18.02
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `absensi`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `absensi`
--

CREATE TABLE `absensi` (
  `id_absensi` int(11) NOT NULL,
  `nim` varchar(20) NOT NULL,
  `id_pertemuan` int(11) NOT NULL,
  `id_sesi` int(11) DEFAULT NULL,
  `status` enum('hadir','izin','sakit','alpha') DEFAULT 'hadir',
  `waktu_absen` datetime DEFAULT current_timestamp(),
  `metode` enum('face_recognition','manual','qr_code') DEFAULT 'face_recognition',
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `barcode`
--

CREATE TABLE `barcode` (
  `id_barcode` int(11) NOT NULL,
  `kode_barcode` varchar(255) NOT NULL,
  `id_sesi` int(11) NOT NULL,
  `nip_dosen` varchar(20) NOT NULL,
  `waktu_dibuat` datetime DEFAULT current_timestamp(),
  `waktu_kadaluarsa` datetime DEFAULT NULL,
  `status` enum('aktif','kadaluarsa') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `dosen`
--

CREATE TABLE `dosen` (
  `nip` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `foto_wajah` varchar(255) DEFAULT NULL,
  `face_descriptor` text DEFAULT NULL,
  `face_registered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `dosen`
--

INSERT INTO `dosen` (`nip`, `nama`, `email`, `no_hp`, `foto_wajah`, `face_descriptor`, `face_registered`, `created_at`, `updated_at`) VALUES
('198501012010121001', 'Dr. Ahmad Hidayat, M.Kom', 'ahmad@univ.ac.id', '081234567890', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('198601012011012001', 'Dr. Siti Nurhaliza, M.T', 'siti@univ.ac.id', '081234567891', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('198701012012011001', 'Prof. Budi Santoso, Ph.D', 'budi@univ.ac.id', '081234567892', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42');

--
-- Trigger `dosen`
--
DELIMITER $$
CREATE TRIGGER `tr_after_face_register_dosen` AFTER UPDATE ON `dosen` FOR EACH ROW BEGIN
    IF NEW.face_registered = 1 AND OLD.face_registered = 0 THEN
        INSERT INTO face_scan_log (user_type, user_id, action)
        VALUES ('dosen', NEW.nip, 'register');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `face_scan_log`
--

CREATE TABLE `face_scan_log` (
  `id_log` int(11) NOT NULL,
  `user_type` enum('dosen','mahasiswa') NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `action` enum('register','verify','failed','update') NOT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `device_info` varchar(255) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelas`
--

CREATE TABLE `kelas` (
  `id_kelas` int(11) NOT NULL,
  `nama_kelas` varchar(50) NOT NULL,
  `id_matakuliah` int(11) NOT NULL,
  `tahun_ajaran` varchar(20) DEFAULT NULL,
  `semester` varchar(10) DEFAULT NULL,
  `ruangan` varchar(50) DEFAULT NULL,
  `hari` varchar(20) DEFAULT NULL,
  `jam_mulai` time DEFAULT NULL,
  `jam_selesai` time DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kelas`
--

INSERT INTO `kelas` (`id_kelas`, `nama_kelas`, `id_matakuliah`, `tahun_ajaran`, `semester`, `ruangan`, `hari`, `jam_mulai`, `jam_selesai`, `created_at`) VALUES
(1, 'TIF-3A', 1, '2024/2025', 'Ganjil', 'Lab Komputer 1', 'Senin', '08:00:00', '10:30:00', '2025-11-23 16:58:42'),
(2, 'TIF-3B', 2, '2024/2025', 'Ganjil', 'Lab Komputer 2', 'Selasa', '10:30:00', '13:00:00', '2025-11-23 16:58:42'),
(3, 'TIF-5A', 3, '2024/2025', 'Ganjil', 'Ruang 301', 'Rabu', '13:00:00', '15:30:00', '2025-11-23 16:58:42');

-- --------------------------------------------------------

--
-- Struktur dari tabel `mahasiswa`
--

CREATE TABLE `mahasiswa` (
  `nim` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `angkatan` varchar(10) DEFAULT NULL,
  `foto_wajah` varchar(255) DEFAULT NULL,
  `face_descriptor` text DEFAULT NULL,
  `face_registered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `mahasiswa`
--

INSERT INTO `mahasiswa` (`nim`, `nama`, `email`, `no_hp`, `id_kelas`, `angkatan`, `foto_wajah`, `face_descriptor`, `face_registered`, `created_at`, `updated_at`) VALUES
('200101001', 'Eko Prasetyo', 'eko@student.univ.ac.id', '081234567897', 3, '2020', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101001', 'Andi Pratama', 'andi@student.univ.ac.id', '081234567893', 1, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101002', 'Budi Setiawan', 'budi@student.univ.ac.id', '081234567894', 1, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101003', 'Citra Dewi', 'citra@student.univ.ac.id', '081234567895', 1, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101004', 'Dian Permata', 'dian@student.univ.ac.id', '081234567896', 2, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42');

--
-- Trigger `mahasiswa`
--
DELIMITER $$
CREATE TRIGGER `tr_after_face_register_mahasiswa` AFTER UPDATE ON `mahasiswa` FOR EACH ROW BEGIN
    IF NEW.face_registered = 1 AND OLD.face_registered = 0 THEN
        INSERT INTO face_scan_log (user_type, user_id, action)
        VALUES ('mahasiswa', NEW.nim, 'register');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `matakuliah`
--

CREATE TABLE `matakuliah` (
  `id_matakuliah` int(11) NOT NULL,
  `kode_mk` varchar(20) NOT NULL,
  `nama_matakuliah` varchar(100) NOT NULL,
  `sks` int(11) NOT NULL,
  `semester` int(11) DEFAULT NULL,
  `nip_dosen` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `matakuliah`
--

INSERT INTO `matakuliah` (`id_matakuliah`, `kode_mk`, `nama_matakuliah`, `sks`, `semester`, `nip_dosen`, `created_at`) VALUES
(1, 'TIF101', 'Pemrograman Web', 3, 3, '198501012010121001', '2025-11-23 16:58:42'),
(2, 'TIF102', 'Basis Data', 3, 3, '198601012011012001', '2025-11-23 16:58:42'),
(3, 'TIF103', 'Kecerdasan Buatan', 3, 5, '198701012012011001', '2025-11-23 16:58:42');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notif` int(11) NOT NULL,
  `user_type` enum('dosen','mahasiswa','admin') NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `judul` varchar(255) NOT NULL,
  `pesan` text NOT NULL,
  `tipe` enum('info','warning','success','error') DEFAULT 'info',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pertemuan`
--

CREATE TABLE `pertemuan` (
  `id_pertemuan` int(11) NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `pertemuan_ke` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `topik` varchar(255) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pertemuan`
--

INSERT INTO `pertemuan` (`id_pertemuan`, `id_kelas`, `pertemuan_ke`, `tanggal`, `topik`, `deskripsi`, `created_at`) VALUES
(1, 1, 1, '2024-09-02', 'Pengenalan HTML & CSS', NULL, '2025-11-23 16:58:42'),
(2, 1, 2, '2024-09-09', 'JavaScript Dasar', NULL, '2025-11-23 16:58:42'),
(3, 1, 3, '2024-09-16', 'PHP & MySQL', NULL, '2025-11-23 16:58:42'),
(4, 2, 1, '2024-09-03', 'Konsep Database', NULL, '2025-11-23 16:58:42'),
(5, 2, 2, '2024-09-10', 'SQL Query', NULL, '2025-11-23 16:58:42'),
(6, 3, 1, '2024-09-04', 'Pengenalan AI', NULL, '2025-11-23 16:58:42');

-- --------------------------------------------------------

--
-- Struktur dari tabel `sesi_absensi`
--

CREATE TABLE `sesi_absensi` (
  `id_sesi` int(11) NOT NULL,
  `id_pertemuan` int(11) NOT NULL,
  `nip_dosen` varchar(20) NOT NULL,
  `waktu_buka` datetime NOT NULL,
  `waktu_tutup` datetime DEFAULT NULL,
  `status_sesi` enum('aktif','selesai') DEFAULT 'aktif',
  `durasi_menit` int(11) DEFAULT 15,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `radius_meter` int(11) DEFAULT 50,
  `kode_sesi` varchar(10) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Trigger `sesi_absensi`
--
DELIMITER $$
CREATE TRIGGER `tr_after_sesi_opened` AFTER INSERT ON `sesi_absensi` FOR EACH ROW BEGIN
    INSERT INTO notifikasi (user_type, user_id, judul, pesan, tipe)
    SELECT 
        'mahasiswa',
        m.nim,
        'Sesi Absensi Dibuka',
        CONCAT('Sesi absensi untuk pertemuan ke-', p.pertemuan_ke, ' telah dibuka. Segera lakukan absensi!'),
        'info'
    FROM mahasiswa m
    JOIN pertemuan p ON NEW.id_pertemuan = p.id_pertemuan
    WHERE m.id_kelas = p.id_kelas;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `level` enum('admin','dosen','mahasiswa') NOT NULL,
  `nim` varchar(20) DEFAULT NULL,
  `nip` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id_user`, `username`, `password`, `nama`, `level`, `nim`, `nip`, `created_at`) VALUES
(1, 'admin', '123456', 'Administrator', 'admin', NULL, NULL, '2025-11-23 16:58:42'),
(2, 'dosen1', '123456', 'Dr. Ahmad Hidayat, M.Kom', 'dosen', NULL, '198501012010121001', '2025-11-23 16:58:42'),
(3, 'dosen2', '123456', 'Dr. Siti Nurhaliza, M.T', 'dosen', NULL, '198601012011012001', '2025-11-23 16:58:42'),
(4, '220101001', '123456', 'Andi Pratama', 'mahasiswa', '220101001', NULL, '2025-11-23 16:58:42'),
(5, '220101002', '123456', 'Budi Setiawan', 'mahasiswa', '220101002', NULL, '2025-11-23 16:58:42'),
(6, '220101003', '123456', 'Citra Dewi', 'mahasiswa', '220101003', NULL, '2025-11-23 16:58:42');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_rekap_kehadiran`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_rekap_kehadiran` (
`nim` varchar(20)
,`nama` varchar(100)
,`nama_kelas` varchar(50)
,`nama_matakuliah` varchar(100)
,`total_pertemuan` bigint(21)
,`total_kehadiran` bigint(21)
,`hadir` decimal(22,0)
,`izin` decimal(22,0)
,`sakit` decimal(22,0)
,`alpha` decimal(22,0)
,`persentase_kehadiran` decimal(28,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_sesi_aktif`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_sesi_aktif` (
`id_sesi` int(11)
,`id_pertemuan` int(11)
,`nip_dosen` varchar(20)
,`waktu_buka` datetime
,`waktu_tutup` datetime
,`status_sesi` enum('aktif','selesai')
,`durasi_menit` int(11)
,`lokasi_lat` decimal(10,8)
,`lokasi_long` decimal(11,8)
,`radius_meter` int(11)
,`kode_sesi` varchar(10)
,`created_at` timestamp
,`pertemuan_ke` int(11)
,`tanggal` date
,`topik` varchar(255)
,`nama_kelas` varchar(50)
,`nama_matakuliah` varchar(100)
,`nama_dosen` varchar(100)
,`menit_berjalan` bigint(21)
,`sisa_menit` bigint(22)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `v_rekap_kehadiran`
--
DROP TABLE IF EXISTS `v_rekap_kehadiran`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_rekap_kehadiran`  AS SELECT `m`.`nim` AS `nim`, `m`.`nama` AS `nama`, `k`.`nama_kelas` AS `nama_kelas`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, count(`p`.`id_pertemuan`) AS `total_pertemuan`, count(`a`.`id_absensi`) AS `total_kehadiran`, sum(case when `a`.`status` = 'hadir' then 1 else 0 end) AS `hadir`, sum(case when `a`.`status` = 'izin' then 1 else 0 end) AS `izin`, sum(case when `a`.`status` = 'sakit' then 1 else 0 end) AS `sakit`, sum(case when `a`.`status` = 'alpha' then 1 else 0 end) AS `alpha`, round(sum(case when `a`.`status` = 'hadir' then 1 else 0 end) / count(`p`.`id_pertemuan`) * 100,2) AS `persentase_kehadiran` FROM ((((`mahasiswa` `m` join `kelas` `k` on(`m`.`id_kelas` = `k`.`id_kelas`)) join `matakuliah` `mk` on(`k`.`id_matakuliah` = `mk`.`id_matakuliah`)) left join `pertemuan` `p` on(`k`.`id_kelas` = `p`.`id_kelas`)) left join `absensi` `a` on(`p`.`id_pertemuan` = `a`.`id_pertemuan` and `a`.`nim` = `m`.`nim`)) GROUP BY `m`.`nim` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_sesi_aktif`
--
DROP TABLE IF EXISTS `v_sesi_aktif`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sesi_aktif`  AS SELECT `s`.`id_sesi` AS `id_sesi`, `s`.`id_pertemuan` AS `id_pertemuan`, `s`.`nip_dosen` AS `nip_dosen`, `s`.`waktu_buka` AS `waktu_buka`, `s`.`waktu_tutup` AS `waktu_tutup`, `s`.`status_sesi` AS `status_sesi`, `s`.`durasi_menit` AS `durasi_menit`, `s`.`lokasi_lat` AS `lokasi_lat`, `s`.`lokasi_long` AS `lokasi_long`, `s`.`radius_meter` AS `radius_meter`, `s`.`kode_sesi` AS `kode_sesi`, `s`.`created_at` AS `created_at`, `p`.`pertemuan_ke` AS `pertemuan_ke`, `p`.`tanggal` AS `tanggal`, `p`.`topik` AS `topik`, `k`.`nama_kelas` AS `nama_kelas`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, `d`.`nama` AS `nama_dosen`, timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) AS `menit_berjalan`, `s`.`durasi_menit`- timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) AS `sisa_menit` FROM ((((`sesi_absensi` `s` join `pertemuan` `p` on(`s`.`id_pertemuan` = `p`.`id_pertemuan`)) join `kelas` `k` on(`p`.`id_kelas` = `k`.`id_kelas`)) join `matakuliah` `mk` on(`k`.`id_matakuliah` = `mk`.`id_matakuliah`)) join `dosen` `d` on(`s`.`nip_dosen` = `d`.`nip`)) WHERE `s`.`status_sesi` = 'aktif' AND timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) <= `s`.`durasi_menit` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `absensi`
--
ALTER TABLE `absensi`
  ADD PRIMARY KEY (`id_absensi`),
  ADD UNIQUE KEY `unique_absensi` (`nim`,`id_pertemuan`),
  ADD KEY `fk_absensi_pertemuan` (`id_pertemuan`),
  ADD KEY `fk_absensi_sesi` (`id_sesi`);

--
-- Indeks untuk tabel `barcode`
--
ALTER TABLE `barcode`
  ADD PRIMARY KEY (`id_barcode`),
  ADD KEY `fk_barcode_sesi` (`id_sesi`),
  ADD KEY `fk_barcode_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `dosen`
--
ALTER TABLE `dosen`
  ADD PRIMARY KEY (`nip`);

--
-- Indeks untuk tabel `face_scan_log`
--
ALTER TABLE `face_scan_log`
  ADD PRIMARY KEY (`id_log`);

--
-- Indeks untuk tabel `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`id_kelas`),
  ADD KEY `idx_matakuliah` (`id_matakuliah`);

--
-- Indeks untuk tabel `mahasiswa`
--
ALTER TABLE `mahasiswa`
  ADD PRIMARY KEY (`nim`),
  ADD KEY `idx_kelas` (`id_kelas`);

--
-- Indeks untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  ADD PRIMARY KEY (`id_matakuliah`),
  ADD UNIQUE KEY `kode_mk` (`kode_mk`),
  ADD KEY `idx_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notif`);

--
-- Indeks untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  ADD PRIMARY KEY (`id_pertemuan`),
  ADD UNIQUE KEY `unique_pertemuan` (`id_kelas`,`pertemuan_ke`);

--
-- Indeks untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  ADD PRIMARY KEY (`id_sesi`),
  ADD KEY `fk_sesi_pertemuan` (`id_pertemuan`),
  ADD KEY `fk_sesi_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `absensi`
--
ALTER TABLE `absensi`
  MODIFY `id_absensi` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `barcode`
--
ALTER TABLE `barcode`
  MODIFY `id_barcode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `face_scan_log`
--
ALTER TABLE `face_scan_log`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kelas`
--
ALTER TABLE `kelas`
  MODIFY `id_kelas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  MODIFY `id_matakuliah` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notif` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  MODIFY `id_pertemuan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  MODIFY `id_sesi` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `absensi`
--
ALTER TABLE `absensi`
  ADD CONSTRAINT `fk_absensi_mhs` FOREIGN KEY (`nim`) REFERENCES `mahasiswa` (`nim`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_absensi_pertemuan` FOREIGN KEY (`id_pertemuan`) REFERENCES `pertemuan` (`id_pertemuan`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_absensi_sesi` FOREIGN KEY (`id_sesi`) REFERENCES `sesi_absensi` (`id_sesi`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `barcode`
--
ALTER TABLE `barcode`
  ADD CONSTRAINT `fk_barcode_dosen` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`),
  ADD CONSTRAINT `fk_barcode_sesi` FOREIGN KEY (`id_sesi`) REFERENCES `sesi_absensi` (`id_sesi`);

--
-- Ketidakleluasaan untuk tabel `kelas`
--
ALTER TABLE `kelas`
  ADD CONSTRAINT `fk_kelas_mk` FOREIGN KEY (`id_matakuliah`) REFERENCES `matakuliah` (`id_matakuliah`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `mahasiswa`
--
ALTER TABLE `mahasiswa`
  ADD CONSTRAINT `fk_mhs_kelas` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  ADD CONSTRAINT `fk_mk_dosen` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  ADD CONSTRAINT `fk_pertemuan_kelas` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  ADD CONSTRAINT `fk_sesi_dosen` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sesi_pertemuan` FOREIGN KEY (`id_pertemuan`) REFERENCES `pertemuan` (`id_pertemuan`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
