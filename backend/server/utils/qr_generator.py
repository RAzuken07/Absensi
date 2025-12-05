import qrcode
import io
import base64
import json
import secrets
from datetime import datetime

def generate_session_code(id_sesi):
    """
    Generate ultra-short code for session (6 digits only for minimal QR)
    
    Args:
        id_sesi: Session ID
        
    Returns:
        str: Ultra-short session code (6 digits)
    """
    # Generate 6 digit numeric code for SIMPLEST QR
    import random
    random_num = random.randint(1000, 9999)  # 4 digit random
    return f"{id_sesi:02d}{random_num}"  # 6 digits total

def generate_qr_code(data, size=10):
    """
    Generate QR code from data with minimal complexity
    
    Args:
        data: Data to encode (dict or string)
        size: QR code size (default 10)
        
    Returns:
        str: Base64 encoded QR code image
    """
    # Convert dict to JSON string if needed
    if isinstance(data, dict):
        data = json.dumps(data)
    
    # Create QR code with MINIMUM complexity
    qr = qrcode.QRCode(
        version=1,  # Version 1 = smallest (21x21 modules)
        error_correction=qrcode.constants.ERROR_CORRECT_L,  # Lowest error correction = simpler
        box_size=size,
        border=2,  # Minimal border
    )
    qr.add_data(data)
    qr.make(fit=False)  # Don't auto-fit to avoid increasing version
    
    # Create image
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Convert to base64
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    img_str = base64.b64encode(buffer.getvalue()).decode()
    
    return f"data:image/png;base64,{img_str}"

def create_session_qr(id_sesi, id_pertemuan, nip_dosen, kode_sesi):
    """
    Create QR code for attendance session
    
    Args:
        id_sesi: Session ID
        id_pertemuan: Meeting ID
        nip_dosen: Lecturer NIP
        kode_sesi: Session code
        
    Returns:
        dict: QR code data and image
    """
    qr_data = {
        'id_sesi': id_sesi,
        'id_pertemuan': id_pertemuan,
        'nip_dosen': nip_dosen,
        'kode_sesi': kode_sesi,
        'timestamp': datetime.now().isoformat()
    }
    
    qr_image = generate_qr_code(qr_data)
    
    return {
        'data': qr_data,
        'image': qr_image,
        'kode_sesi': kode_sesi
    }

def validate_qr_data(scanned_data, expected_sesi_id):
    """
    Validate scanned QR code data
    
    Args:
        scanned_data: Data from scanned QR code (string or dict)
        expected_sesi_id: Expected session ID
        
    Returns:
        tuple: (bool: is_valid, dict: data or error)
    """
    try:
        # Parse JSON if string
        if isinstance(scanned_data, str):
            data = json.loads(scanned_data)
        else:
            data = scanned_data
        
        # Validate structure
        required_fields = ['id_sesi', 'id_pertemuan', 'kode_sesi']
        if not all(field in data for field in required_fields):
            return False, {'error': 'Invalid QR code format'}
        
        # Validate session ID
        if data['id_sesi'] != expected_sesi_id:
            return False, {'error': 'QR code does not match current session'}
        
        return True, data
        
    except json.JSONDecodeError:
        return False, {'error': 'Invalid QR code data'}
    except Exception as e:
        return False, {'error': f'QR validation error: {str(e)}'}
