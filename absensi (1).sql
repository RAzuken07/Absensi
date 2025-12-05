-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 05 Des 2025 pada 04.30
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
  `status` enum('hadir','alpha','izin','sakit','terlambat') DEFAULT 'alpha',
  `waktu_absen` datetime DEFAULT current_timestamp(),
  `metode` enum('face_recognition','manual','qr_code') DEFAULT 'face_recognition',
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `foto_selfie` varchar(255) DEFAULT NULL,
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

--
-- Dumping data untuk tabel `barcode`
--

INSERT INTO `barcode` (`id_barcode`, `kode_barcode`, `id_sesi`, `nip_dosen`, `waktu_dibuat`, `waktu_kadaluarsa`, `status`) VALUES
(13, '136418', 13, '198501012010121001', '2025-12-04 23:21:32', '2025-12-05 00:51:32', 'kadaluarsa');

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
('123456789', 'dr.ddda', 'rr@gmail.com', '088636316313', NULL, NULL, 0, '2025-12-03 05:35:17', '2025-12-03 05:35:17'),
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

--
-- Dumping data untuk tabel `face_scan_log`
--

INSERT INTO `face_scan_log` (`id_log`, `user_type`, `user_id`, `action`, `confidence_score`, `ip_address`, `device_info`, `user_agent`, `lokasi_lat`, `lokasi_long`, `created_at`) VALUES
(1, 'mahasiswa', '2023573010108', 'register', NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-03 09:36:19');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kelas`
--

INSERT INTO `kelas` (`id_kelas`, `nama_kelas`, `id_matakuliah`, `tahun_ajaran`, `semester`, `created_at`) VALUES
(3, 'TIF-5A', 3, '2024/2025', 'Ganjil', '2025-11-23 16:58:42'),
(4, 'TI3E', 3, '2025/2026', 'ganjil', '2025-12-02 20:29:49'),
(6, 'TIF-3A', 1, '2024/2025', 'Ganjil', '2025-12-03 05:17:11'),
(7, 'TIF-3B', 2, '2024/2025', 'Ganjil', '2025-12-03 05:17:11'),
(9, 'test', 5, '2024/2025', 'ganjil', '2025-12-03 05:37:45');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelas_dosen`
--

CREATE TABLE `kelas_dosen` (
  `id_kelas_dosen` int(11) NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `nip_dosen` varchar(20) NOT NULL,
  `tahun_ajaran` varchar(20) DEFAULT NULL,
  `semester` varchar(10) DEFAULT NULL,
  `ruangan` varchar(50) DEFAULT NULL,
  `hari` varchar(20) DEFAULT NULL,
  `jam_mulai` time DEFAULT NULL,
  `jam_selesai` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kelas_dosen`
--

INSERT INTO `kelas_dosen` (`id_kelas_dosen`, `id_kelas`, `nip_dosen`, `tahun_ajaran`, `semester`, `ruangan`, `hari`, `jam_mulai`, `jam_selesai`) VALUES
(3, 3, '198701012012011001', '2024/2025', 'Ganjil', NULL, NULL, NULL, NULL),
(8, 6, '198501012010121001', '2024/2025', 'Ganjil', NULL, NULL, NULL, NULL),
(9, 7, '198601012011012001', '2024/2025', 'Ganjil', NULL, NULL, NULL, NULL);

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
('2023573010108', 'rizki', 'rr3433735@gmail.com', '082181871520', 4, '2023', NULL, '[-0.207145094871521, 0.1358080953359604, 0.09232035279273987, -0.03548525273799896, -0.09082332253456116, 0.0051550595089793205, 0.02266954816877842, -0.05303414165973663, 0.15609028935432434, -0.001989683136343956, 0.30046966671943665, -0.04824056103825569, -0.2153589129447937, -0.17848140001296997, 0.06183052062988281, 0.17850233614444733, -0.12446271628141403, -0.16306114196777344, -0.054171428084373474, -0.013682214543223381, 0.02862570807337761, 0.009470641613006592, 0.005455571226775646, 0.1105765700340271, -0.1585761308670044, -0.4162220358848572, -0.051073115319013596, -0.14695213735103607, -0.008333378471434116, -0.06009281054139137, -0.004048274829983711, 0.09005442261695862, -0.20548219978809357, -0.019106363877654076, -0.056095633655786514, 0.05641193687915802, 0.05197601020336151, 0.044385917484760284, 0.1495932638645172, -0.010390200652182102, -0.2648378908634186, -0.006797427777200937, 0.010206039994955063, 0.26225677132606506, 0.15419043600559235, -0.029482323676347733, 0.019622068852186203, 0.06024082750082016, 0.018604781478643417, -0.20571188628673553, -0.02004684880375862, 0.13673712313175201, 0.1591617912054062, -0.002506786957383156, 0.009685659781098366, -0.1346578747034073, -0.046745993196964264, 0.07996612787246704, -0.19568704068660736, 0.010639818385243416, -0.04716292396187782, -0.11741937696933746, -0.04754219949245453, -0.0647042989730835, 0.2353162318468094, 0.0848248302936554, -0.12726546823978424, -0.11136628687381744, 0.09957315027713776, -0.09147214889526367, -0.018161341547966003, 0.11460806429386139, -0.1818312108516693, -0.17637304961681366, -0.39328429102897644, 0.10838824510574341, 0.35298043489456177, 0.050663791596889496, -0.28134334087371826, -0.005733153782784939, -0.10447309166193008, 0.04384681582450867, -0.0211260337382555, 0.04602779075503349, -0.07747316360473633, 0.024182051420211792, -0.16622062027454376, 0.0034685470163822174, 0.1413978636264801, -0.03154517337679863, 0.006663491949439049, 0.23239706456661224, 0.00021101068705320358, 0.0571138970553875, -0.015420475974678993, 0.06663786619901657, -0.0032466156408190727, -0.05223549157381058, -0.07792404294013977, 0.02462092414498329, 0.017577864229679108, -0.06431213021278381, -0.03555106744170189, 0.07885626703500748, -0.23670481145381927, 0.09703925251960754, 0.05049934983253479, -0.009551244787871838, -0.05700158327817917, 0.09284256398677826, -0.06718099117279053, -0.07955221086740494, 0.13944284617900848, -0.23446564376354218, 0.17938868701457977, 0.2256888896226883, -0.018624471500515938, 0.14170023798942566, 0.056095946580171585, 0.019805187359452248, -0.10981298238039017, -0.023086657747626305, -0.07952708750963211, -0.04024973139166832, 0.13988454639911652, -0.10171462595462799, 0.033124566078186035, 0.038663119077682495]', 1, '2025-12-03 05:46:25', '2025-12-03 09:36:19'),
('220101001', 'Andi Pratama', 'andi@student.univ.ac.id', '081234567893', NULL, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101002', 'Budi Setiawan', 'budi@student.univ.ac.id', '081234567894', NULL, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101003', 'Citra Dewi', 'citra@student.univ.ac.id', '081234567895', NULL, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42'),
('220101004', 'Dian Permata', 'dian@student.univ.ac.id', '081234567896', NULL, '2022', NULL, NULL, 0, '2025-11-23 16:58:42', '2025-11-23 16:58:42');

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
(3, 'TIF103', 'Kecerdasan Buatan', 3, 5, '198701012012011001', '2025-11-23 16:58:42'),
(4, 'MTR', 'Matematika Teoi Ropot', 3, 4, '198601012011012001', '2025-12-02 20:30:47'),
(5, 'MKS', 'mata kuliah sakit', 3, 3, '123456789', '2025-12-03 05:36:18');

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
(6, 3, 1, '2024-09-04', 'Pengenalan AI', NULL, '2025-11-23 16:58:42'),
(19, 6, 1, '2025-12-04', 'Pertemuan ke-1', NULL, '2025-12-04 16:21:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `sesi_absensi`
--

CREATE TABLE `sesi_absensi` (
  `id_sesi` int(11) NOT NULL,
  `id_pertemuan` int(11) NOT NULL,
  `nama_kelas` varchar(50) DEFAULT NULL,
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
-- Dumping data untuk tabel `sesi_absensi`
--

INSERT INTO `sesi_absensi` (`id_sesi`, `id_pertemuan`, `nama_kelas`, `nip_dosen`, `waktu_buka`, `waktu_tutup`, `status_sesi`, `durasi_menit`, `lokasi_lat`, `lokasi_long`, `radius_meter`, `kode_sesi`, `created_at`) VALUES
(13, 19, NULL, '198501012010121001', '2025-12-04 23:21:32', '2025-12-04 23:21:59', 'selesai', 90, 5.11922000, 97.15678000, 50, '136418', '2025-12-04 16:21:32');

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
(6, '220101003', '123456', 'Citra Dewi', 'mahasiswa', '220101003', NULL, '2025-11-23 16:58:42'),
(7, '123456789', '$2b$12$8sKxSm1O3GoInZgkyW0A0.nByb7HytWod9uEFWe34QkRzThsgQSAm', 'dr.ddda', 'dosen', NULL, '123456789', '2025-12-03 05:35:17'),
(9, 'rizky', '$2b$12$Y2VdXTgLvp6LjkAwrg1AtOKoqe81jjohFPOgSCWqv2btsK.WfwLy2', 'rizki', 'mahasiswa', '2023573010108', NULL, '2025-12-03 05:46:25');

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
  ADD KEY `idx_nim` (`nim`),
  ADD KEY `idx_sesi` (`id_sesi`),
  ADD KEY `idx_pertemuan` (`id_pertemuan`);

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
-- Indeks untuk tabel `kelas_dosen`
--
ALTER TABLE `kelas_dosen`
  ADD PRIMARY KEY (`id_kelas_dosen`),
  ADD KEY `id_kelas` (`id_kelas`),
  ADD KEY `nip_dosen` (`nip_dosen`);

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
  MODIFY `id_barcode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `face_scan_log`
--
ALTER TABLE `face_scan_log`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `kelas`
--
ALTER TABLE `kelas`
  MODIFY `id_kelas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `kelas_dosen`
--
ALTER TABLE `kelas_dosen`
  MODIFY `id_kelas_dosen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  MODIFY `id_matakuliah` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notif` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  MODIFY `id_pertemuan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  MODIFY `id_sesi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
-- Ketidakleluasaan untuk tabel `kelas_dosen`
--
ALTER TABLE `kelas_dosen`
  ADD CONSTRAINT `kelas_dosen_ibfk_1` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`) ON DELETE CASCADE,
  ADD CONSTRAINT `kelas_dosen_ibfk_2` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`) ON DELETE CASCADE;

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
