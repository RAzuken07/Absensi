from database.db import Database
from utils.qr_generator import generate_session_code, generate_qr_code
from datetime import datetime

class DosenService:
    """Service for dosen operations"""
    
    @staticmethod
    def get_kelas_by_dosen(nip_dosen):
        """Get all kelas taught by dosen (through kelas_dosen junction table)"""
        query = """
            SELECT k.*, mk.nama_matakuliah, mk.kode_mk, kd.tahun_ajaran, kd.semester
            FROM kelas_dosen kd
            JOIN kelas k ON kd.id_kelas = k.id_kelas
            LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            WHERE kd.nip_dosen = %s
            ORDER BY k.nama_kelas
        """
        results = Database.execute_query(query, (nip_dosen,), fetch_all=True)
        
        # Convert time objects to string for JSON serialization
        if results:
            for row in results:
                if row.get('jam_mulai'):
                    row['jam_mulai'] = str(row['jam_mulai'])
                if row.get('jam_selesai'):
                    row['jam_selesai'] = str(row['jam_selesai'])
        
        return results
    
    @staticmethod
    def get_pertemuan_by_kelas(id_kelas):
        """Get all pertemuan for a kelas"""
        query = """
            SELECT * FROM pertemuan
            WHERE id_kelas = %s
            ORDER BY pertemuan_ke
        """
        return Database.execute_query(query, (id_kelas,), fetch_all=True)
    
    @staticmethod
    def create_pertemuan(data):
        """Create new pertemuan"""
        try:
            query = """
                INSERT INTO pertemuan (id_kelas, pertemuan_ke, tanggal, topik, deskripsi)
                VALUES (%s, %s, %s, %s, %s)
            """
            pertemuan_id = Database.execute_query(
                query,
                (data['id_kelas'], data['pertemuan_ke'], data['tanggal'], 
                 data.get('topik'), data.get('deskripsi')),
                commit=True
            )
            
            return True, pertemuan_id
            
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def open_sesi_absensi(data, nip_dosen):
        """Open attendance session with auto-generated values"""
        try:
            id_kelas = data['id_kelas']
            
            # Auto-generate pertemuan_ke (get max + 1)
            query_max = """
                SELECT COALESCE(MAX(pertemuan_ke), 0) as max_pertemuan 
                FROM pertemuan 
                WHERE id_kelas = %s
            """
            result = Database.execute_query(query_max, (id_kelas,), fetch_one=True)
            pertemuan_ke = (result['max_pertemuan'] if result else 0) + 1
            
            # Use defaults or provided values
            durasi_menit = data.get('durasi_menit', 90)  # Default 90 minutes
            topik = data.get('topik', f'Pertemuan ke-{pertemuan_ke}')
            lokasi_lat = data.get('lokasi_lat', 5.11922)  # Default: PNL campus
            lokasi_long = data.get('lokasi_long', 97.15678)
            radius_meter = data.get('radius_meter', 50)  # Default 50m
            
            # Create pertemuan first
            tanggal = datetime.now().date()
            query_pertemuan = """
                INSERT INTO pertemuan (id_kelas, pertemuan_ke, tanggal, topik)
                VALUES (%s, %s, %s, %s)
            """
            id_pertemuan = Database.execute_query(
                query_pertemuan,
                (id_kelas, pertemuan_ke, tanggal, topik),
                commit=True
            )
            
            # Insert sesi
            query_sesi = """
                INSERT INTO sesi_absensi 
                (id_pertemuan, nip_dosen, waktu_buka, durasi_menit, 
                 lokasi_lat, lokasi_long, radius_meter, status_sesi)
                VALUES (%s, %s, NOW(), %s, %s, %s, %s, 'aktif')
            """
            id_sesi = Database.execute_query(
                query_sesi,
                (id_pertemuan, nip_dosen, durasi_menit, 
                 lokasi_lat, lokasi_long, radius_meter),
                commit=True
            )
            
            # Generate session code
            kode_sesi = generate_session_code(id_sesi)
            
            # Update sesi with kode
            query_update = "UPDATE sesi_absensi SET kode_sesi = %s WHERE id_sesi = %s"
            Database.execute_query(query_update, (kode_sesi, id_sesi), commit=True)
            
            # Return kode_sesi as plain string for frontend to generate QR
            qr_data = kode_sesi
            
            
            # Insert barcode record
            query_barcode = """
                INSERT INTO barcode (kode_barcode, id_sesi, nip_dosen, waktu_kadaluarsa, status)
                VALUES (%s, %s, %s, DATE_ADD(NOW(), INTERVAL %s MINUTE), 'aktif')
            """
            Database.execute_query(
                query_barcode,
                (kode_sesi, id_sesi, nip_dosen, durasi_menit),
                commit=True
            )
            
            return True, {
                'id_sesi': id_sesi,
                'id_pertemuan': id_pertemuan,
                'pertemuan_ke': pertemuan_ke,
                'kode_sesi': kode_sesi,
                'qr_data': qr_data,
                'durasi_menit': durasi_menit,
                'waktu_buka': datetime.now().isoformat()
            }
            
        except Exception as e:
            print(f"Error opening sesi: {e}")
            return False, str(e)
    
    @staticmethod
    def close_sesi_absensi(id_sesi, nip_dosen):
        """Close attendance session"""
        try:
            # Verify dosen owns this session
            query_check = "SELECT id_sesi FROM sesi_absensi WHERE id_sesi = %s AND nip_dosen = %s"
            result = Database.execute_query(query_check, (id_sesi, nip_dosen), fetch_one=True)
            
            if not result:
                return False, "Session not found or unauthorized"
            
            # Update sesi status
            query_update = """
                UPDATE sesi_absensi 
                SET status_sesi = 'selesai', waktu_tutup = NOW()
                WHERE id_sesi = %s
            """
            Database.execute_query(query_update, (id_sesi,), commit=True)
            
            # Update barcode status
            query_barcode = """
                UPDATE barcode 
                SET status = 'kadaluarsa'
                WHERE id_sesi = %s
            """
            Database.execute_query(query_barcode, (id_sesi,), commit=True)
            
            return True, "Session closed successfully"
            
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def get_rekap_kehadiran(id_kelas):
        """Get attendance recap for a class"""
        query = """
            SELECT 
                m.nim, m.nama,
                COUNT(DISTINCT p.id_pertemuan) as total_pertemuan,
                COUNT(DISTINCT CASE WHEN a.status = 'hadir' THEN a.id_absensi END) as hadir,
                COUNT(DISTINCT CASE WHEN a.status = 'izin' THEN a.id_absensi END) as izin,
                COUNT(DISTINCT CASE WHEN a.status = 'sakit' THEN a.id_absensi END) as sakit,
                COUNT(DISTINCT CASE WHEN a.status = 'alpha' THEN a.id_absensi END) as alpha,
                ROUND(
                    COUNT(DISTINCT CASE WHEN a.status = 'hadir' THEN a.id_absensi END) / 
                    COUNT(DISTINCT p.id_pertemuan) * 100, 2
                ) as persentase_kehadiran
            FROM mahasiswa m
            CROSS JOIN pertemuan p
            LEFT JOIN absensi a ON a.nim = m.nim AND a.id_pertemuan = p.id_pertemuan
            WHERE m.id_kelas = %s AND p.id_kelas = %s
            GROUP BY m.nim, m.nama
            ORDER BY m.nama
        """
        return Database.execute_query(query, (id_kelas, id_kelas), fetch_all=True)
    
    @staticmethod
    def get_active_sessions(nip_dosen):
        """Get active sessions for dosen"""
        query = """
            SELECT 
                s.id_sesi,
                s.id_pertemuan,
                s.waktu_buka,
                s.waktu_tutup,
                s.durasi_menit,
                s.status_sesi,
                s.kode_sesi,
                p.pertemuan_ke,
                p.topik,
                p.tanggal,
                k.id_kelas,
                k.nama_kelas,
                mk.nama_matakuliah,
                mk.kode_mk,
                COUNT(DISTINCT a.id_absensi) as jumlah_hadir
            FROM sesi_absensi s
            JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
            JOIN kelas k ON p.id_kelas = k.id_kelas
            LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            LEFT JOIN absensi a ON s.id_sesi = a.id_sesi
            WHERE s.nip_dosen = %s AND s.status_sesi = 'aktif'
            GROUP BY s.id_sesi, s.id_pertemuan, s.waktu_buka, s.waktu_tutup, 
                     s.durasi_menit, s.status_sesi, s.kode_sesi,
                     p.pertemuan_ke, p.topik, p.tanggal,
                     k.id_kelas, k.nama_kelas, mk.nama_matakuliah, mk.kode_mk
            ORDER BY s.waktu_buka DESC
        """
        results = Database.execute_query(query, (nip_dosen,), fetch_all=True)
        
        # Convert datetime to string for JSON
        if results:
            for row in results:
                if row.get('waktu_buka'):
                    row['waktu_buka'] = str(row['waktu_buka'])
                if row.get('waktu_tutup'):
                    row['waktu_tutup'] = str(row['waktu_tutup'])
                if row.get('tanggal'):
                    row['tanggal'] = str(row['tanggal'])
        
        return results
    
    @staticmethod
    def get_session_details(id_sesi):
        """Get session details with attendance list"""
        # Get session info
        query_sesi = """
            SELECT s.*, p.pertemuan_ke, p.topik, k.nama_kelas, mk.nama_matakuliah
            FROM sesi_absensi s
            JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
            JOIN kelas k ON p.id_kelas = k.id_kelas
            JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            WHERE s.id_sesi = %s
        """
        sesi = Database.execute_query(query_sesi, (id_sesi,), fetch_one=True)
        
        if not sesi:
            return None
        
        # Get attendance list
        query_attendance = """
            SELECT a.*, m.nama, m.nim
            FROM absensi a
            JOIN mahasiswa m ON a.nim = m.nim
            WHERE a.id_sesi = %s
            ORDER BY a.waktu_absen
        """
        attendance = Database.execute_query(query_attendance, (id_sesi,), fetch_all=True)
        
        sesi['attendance_list'] = attendance
        sesi['total_absen'] = len(attendance)
        
        return sesi
    
    @staticmethod
    def get_absensi_by_pertemuan(id_pertemuan):
        """Get all students with their attendance status for a pertemuan"""
        try:
            # Get all mahasiswa in the kelas for this pertemuan
            query = """
                SELECT 
                    m.nim,
                    m.nama,
                    COALESCE(a.status, 'belum_absen') as status,
                    a.waktu_absen
                FROM pertemuan p
                JOIN kelas k ON p.id_kelas = k.id_kelas
                CROSS JOIN mahasiswa m
                LEFT JOIN sesi_absensi s ON s.id_pertemuan = p.id_pertemuan
                LEFT JOIN absensi a ON a.nim = m.nim AND a.id_sesi = s.id_sesi
                WHERE p.id_pertemuan = %s AND m.id_kelas = k.id_kelas
                ORDER BY m.nama
            """
            results = Database.execute_query(query, (id_pertemuan,), fetch_all=True)
            
            # Convert waktu_absen to string if exists
            if results:
                for row in results:
                    if row.get('waktu_absen'):
                        row['waktu_absen'] = str(row['waktu_absen'])
            
            return results
        except Exception as e:
            print(f"Error in get_absensi_by_pertemuan: {e}")
            return []
    
    @staticmethod
    def get_pertemuan_status_by_kelas(id_kelas):
        """Get list of pertemuan that have sessions created (returns pertemuan_ke numbers)"""
        try:
            query = """
                SELECT DISTINCT p.pertemuan_ke
                FROM pertemuan p
                INNER JOIN sesi_absensi s ON s.id_pertemuan = p.id_pertemuan
                WHERE p.id_kelas = %s
                ORDER BY p.pertemuan_ke
            """
            results = Database.execute_query(query, (id_kelas,), fetch_all=True)
            
            # Return list of dicts with pertemuan_ke
            return results if results else []
        except Exception as e:
            print(f"Error in get_pertemuan_status_by_kelas: {e}")
            return []

