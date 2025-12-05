from database.db import Database
from utils.password_hash import hash_password

class AdminService:
    """Service for admin operations"""
    
    # ============ DOSEN MANAGEMENT ============
    
    @staticmethod
    def get_all_dosen():
        """Get all dosen"""
        query = "SELECT * FROM dosen ORDER BY nama"
        return Database.execute_query(query, fetch_all=True)
    
    @staticmethod
    def get_dosen_by_nip(nip):
        """Get dosen by NIP"""
        query = "SELECT * FROM dosen WHERE nip = %s"
        return Database.execute_query(query, (nip,), fetch_one=True)
    
    @staticmethod
    def create_dosen(data):
        """Create new dosen"""
        try:
            # Insert into dosen table
            query_dosen = """
                INSERT INTO dosen (nip, nama, email, no_hp)
                VALUES (%s, %s, %s, %s)
            """
            Database.execute_query(
                query_dosen,
                (data['nip'], data['nama'], data['email'], data.get('no_hp')),
                commit=True
            )
            
            # Create user account if username and password provided
            if 'username' in data and 'password' in data:
                hashed_password = hash_password(data['password'])
                query_user = """
                    INSERT INTO users (username, password, nama, level, nip)
                    VALUES (%s, %s, %s, 'dosen', %s)
                """
                Database.execute_query(
                    query_user,
                    (data['username'], hashed_password, data['nama'], data['nip']),
                    commit=True
                )
            
            return True, "Dosen created successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def update_dosen(nip, data):
        """Update dosen"""
        try:
            query = """
                UPDATE dosen 
                SET nama = %s, email = %s, no_hp = %s
                WHERE nip = %s
            """
            Database.execute_query(
                query,
                (data['nama'], data['email'], data.get('no_hp'), nip),
                commit=True
            )
            return True, "Dosen updated successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def delete_dosen(nip):
        """Delete dosen"""
        try:
            # Delete from dosen table (cascades to related tables)
            query = "DELETE FROM dosen WHERE nip = %s"
            Database.execute_query(query, (nip,), commit=True)
            
            # Delete user account
            query_user = "DELETE FROM users WHERE nip = %s"
            Database.execute_query(query_user, (nip,), commit=True)
            
            return True, "Dosen deleted successfully"
        except Exception as e:
            return False, str(e)
    
    # ============ MAHASISWA MANAGEMENT ============
    
    @staticmethod
    def get_all_mahasiswa():
        """Get all mahasiswa with kelas info"""
        query = """
            SELECT m.*, k.nama_kelas 
            FROM mahasiswa m
            LEFT JOIN kelas k ON m.id_kelas = k.id_kelas
            ORDER BY m.nama
        """
        return Database.execute_query(query, fetch_all=True)
    
    @staticmethod
    def get_mahasiswa_by_nim(nim):
        """Get mahasiswa by NIM"""
        query = """
            SELECT m.*, k.nama_kelas 
            FROM mahasiswa m
            LEFT JOIN kelas k ON m.id_kelas = k.id_kelas
            WHERE m.nim = %s
        """
        return Database.execute_query(query, (nim,), fetch_one=True)
    
    @staticmethod
    def create_mahasiswa(data):
        """Create new mahasiswa"""
        try:
            # Insert into mahasiswa table
            query_mhs = """
                INSERT INTO mahasiswa (nim, nama, email, no_hp, id_kelas, angkatan)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            Database.execute_query(
                query_mhs,
                (data['nim'], data['nama'], data['email'], 
                 data.get('no_hp'), data.get('id_kelas'), data.get('angkatan')),
                commit=True
            )
            
            # Create user account if username and password provided
            if 'username' in data and 'password' in data:
                hashed_password = hash_password(data['password'])
                query_user = """
                    INSERT INTO users (username, password, nama, level, nim)
                    VALUES (%s, %s, %s, 'mahasiswa', %s)
                """
                Database.execute_query(
                    query_user,
                    (data['username'], hashed_password, data['nama'], data['nim']),
                    commit=True
                )
            
            return True, "Mahasiswa created successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def update_mahasiswa(nim, data):
        """Update mahasiswa"""
        try:
            query = """
                UPDATE mahasiswa 
                SET nama = %s, email = %s, no_hp = %s, id_kelas = %s, angkatan = %s
                WHERE nim = %s
            """
            Database.execute_query(
                query,
                (data['nama'], data['email'], data.get('no_hp'), 
                 data.get('id_kelas'), data.get('angkatan'), nim),
                commit=True
            )
            return True, "Mahasiswa updated successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def delete_mahasiswa(nim):
        """Delete mahasiswa"""
        try:
            query = "DELETE FROM mahasiswa WHERE nim = %s"
            Database.execute_query(query, (nim,), commit=True)
            
            # Delete user account
            query_user = "DELETE FROM users WHERE nim = %s"
            Database.execute_query(query_user, (nim,), commit=True)
            
            return True, "Mahasiswa deleted successfully"
        except Exception as e:
            return False, str(e)
    
    # ============ MATA KULIAH MANAGEMENT ============
    
    @staticmethod
    def get_all_matakuliah():
        """Get all mata kuliah with dosen info"""
        query = """
            SELECT mk.*, d.nama as nama_dosen 
            FROM matakuliah mk
            LEFT JOIN dosen d ON mk.nip_dosen = d.nip
            ORDER BY mk.nama_matakuliah
        """
        return Database.execute_query(query, fetch_all=True)
    
    @staticmethod
    def get_matakuliah_by_id(id_matakuliah):
        """Get mata kuliah by ID"""
        query = """
            SELECT mk.*, d.nama as nama_dosen 
            FROM matakuliah mk
            LEFT JOIN dosen d ON mk.nip_dosen = d.nip
            WHERE mk.id_matakuliah = %s
        """
        return Database.execute_query(query, (id_matakuliah,), fetch_one=True)
    
    @staticmethod
    def create_matakuliah(data):
        """Create new mata kuliah"""
        try:
            query = """
                INSERT INTO matakuliah (kode_mk, nama_matakuliah, sks, semester, nip_dosen)
                VALUES (%s, %s, %s, %s, %s)
            """
            Database.execute_query(
                query,
                (data['kode_mk'], data['nama_matakuliah'], data['sks'], 
                 data.get('semester'), data.get('nip_dosen')),
                commit=True
            )
            return True, "Mata kuliah created successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def update_matakuliah(id_matakuliah, data):
        """Update mata kuliah"""
        try:
            query = """
                UPDATE matakuliah 
                SET kode_mk = %s, nama_matakuliah = %s, sks = %s, 
                    semester = %s, nip_dosen = %s
                WHERE id_matakuliah = %s
            """
            Database.execute_query(
                query,
                (data['kode_mk'], data['nama_matakuliah'], data['sks'], 
                 data.get('semester'), data.get('nip_dosen'), id_matakuliah),
                commit=True
            )
            return True, "Mata kuliah updated successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def delete_matakuliah(id_matakuliah):
        """Delete mata kuliah"""
        try:
            query = "DELETE FROM matakuliah WHERE id_matakuliah = %s"
            Database.execute_query(query, (id_matakuliah,), commit=True)
            return True, "Mata kuliah deleted successfully"
        except Exception as e:
            return False, str(e)
    
    # ============ KELAS MANAGEMENT ============
    
    @staticmethod
    def get_all_kelas():
        """Get all kelas with mata kuliah info"""
        query = """
            SELECT k.*, mk.nama_matakuliah, mk.kode_mk 
            FROM kelas k
            LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            ORDER BY k.nama_kelas
        """
        results = Database.execute_query(query, fetch_all=True)
        
        # Convert time objects to string for JSON serialization
        if results:
            for row in results:
                if row.get('jam_mulai'):
                    row['jam_mulai'] = str(row['jam_mulai'])
                if row.get('jam_selesai'):
                    row['jam_selesai'] = str(row['jam_selesai'])
        
        return results
    
    @staticmethod
    def get_kelas_by_id(id_kelas):
        """Get kelas by ID"""
        query = """
            SELECT k.*, mk.nama_matakuliah, mk.kode_mk 
            FROM kelas k
            LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            WHERE k.id_kelas = %s
        """
        result = Database.execute_query(query, (id_kelas,), fetch_one=True)
        
        # Convert time objects to string for JSON serialization
        if result:
            if result.get('jam_mulai'):
                result['jam_mulai'] = str(result['jam_mulai'])
            if result.get('jam_selesai'):
                result['jam_selesai'] = str(result['jam_selesai'])
        
        return result
    
    @staticmethod
    def create_kelas(data):
        """Create new kelas"""
        try:
            query = """
                INSERT INTO kelas (nama_kelas, id_matakuliah, tahun_ajaran, semester, 
                                   ruangan, hari, jam_mulai, jam_selesai)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            Database.execute_query(
                query,
                (data['nama_kelas'], data['id_matakuliah'], data.get('tahun_ajaran'),
                 data.get('semester'), data.get('ruangan'), data.get('hari'),
                 data.get('jam_mulai'), data.get('jam_selesai')),
                commit=True
            )
            return True, "Kelas created successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def update_kelas(id_kelas, data):
        """Update kelas"""
        try:
            query = """
                UPDATE kelas 
                SET nama_kelas = %s, id_matakuliah = %s, tahun_ajaran = %s, 
                    semester = %s, ruangan = %s, hari = %s, jam_mulai = %s, jam_selesai = %s
                WHERE id_kelas = %s
            """
            Database.execute_query(
                query,
                (data['nama_kelas'], data['id_matakuliah'], data.get('tahun_ajaran'),
                 data.get('semester'), data.get('ruangan'), data.get('hari'),
                 data.get('jam_mulai'), data.get('jam_selesai'), id_kelas),
                commit=True
            )
            return True, "Kelas updated successfully"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def delete_kelas(id_kelas):
        """Delete kelas"""
        try:
            query = "DELETE FROM kelas WHERE id_kelas = %s"
            Database.execute_query(query, (id_kelas,), commit=True)
            return True, "Kelas deleted successfully"
        except Exception as e:
            return False, str(e)
    
    # ============ KELAS-DOSEN ASSIGNMENT ============
    
    @staticmethod
    def assign_dosen_to_kelas(data):
        """Assign dosen and matakuliah to kelas"""
        try:
            print(f"[DEBUG] Received data: {data}")
            query = """
                INSERT INTO kelas_dosen (id_kelas, nip_dosen, id_matakuliah, ruangan, hari, jam_mulai, jam_selesai)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            params = (data['id_kelas'], data['nip'], data['id_matakuliah'],
                     data.get('ruangan'), data.get('hari'), data.get('jam_mulai'), data.get('jam_selesai'))
            print(f"[DEBUG] Query params: {params}")
            
            Database.execute_query(
                query,
                params,
                commit=True
            )
            print("[DEBUG] Insert successful")
            return True, "Dosen and mata kuliah assigned successfully"
        except Exception as e:
            print(f"[ERROR] Failed to assign: {str(e)}")
            import traceback
            traceback.print_exc()
            return False, str(e)
    
    @staticmethod
    def get_dosen_by_kelas(id_kelas):
        """Get all dosen and matakuliah teaching a specific kelas"""
        query = """
            SELECT kd.id_kelas_dosen, kd.id_kelas, kd.nip_dosen, kd.id_matakuliah,
                   kd.ruangan, kd.hari, kd.jam_mulai, kd.jam_selesai,
                   d.nama as nama_dosen,
                   mk.kode_mk, mk.nama_matakuliah as nama_mk, mk.sks
            FROM kelas_dosen kd
            JOIN dosen d ON kd.nip_dosen = d.nip
            JOIN matakuliah mk ON kd.id_matakuliah = mk.id_matakuliah
            WHERE kd.id_kelas = %s
            ORDER BY mk.nama_matakuliah
        """
        return Database.execute_query(query, (id_kelas,), fetch_all=True)
    
    @staticmethod
    def remove_dosen_from_kelas(id_kelas_dosen):
        """Remove dosen from kelas"""
        try:
            query = "DELETE FROM kelas_dosen WHERE id_kelas_dosen = %s"
            Database.execute_query(query, (id_kelas_dosen,), commit=True)
            return True, "Dosen removed from kelas successfully"
        except Exception as e:
            return False, str(e)
