import math

def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two coordinates using Haversine formula
    
    Args:
        lat1, lon1: First coordinate (latitude, longitude)
        lat2, lon2: Second coordinate (latitude, longitude)
        
    Returns:
        float: Distance in meters
    """
    # Earth radius in meters
    R = 6371000
    
    # Convert to radians
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    # Haversine formula
    a = (math.sin(delta_lat / 2) ** 2 +
         math.cos(lat1_rad) * math.cos(lat2_rad) *
         math.sin(delta_lon / 2) ** 2)
    
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c
    
    return distance

def is_within_radius(student_lat, student_lon, sesi_lat, sesi_lon, radius_meters):
    """
    Check if student location is within allowed radius
    
    Args:
        student_lat, student_lon: Student's current location
        sesi_lat, sesi_lon: Session location (campus)
        radius_meters: Allowed radius in meters
        
    Returns:
        tuple: (bool: is_valid, float: actual_distance)
    """
    distance = calculate_distance(student_lat, student_lon, sesi_lat, sesi_lon)
    is_valid = distance <= radius_meters
    
    return is_valid, distance

def validate_location(student_lat, student_lon, sesi_lat, sesi_lon, radius_meters):
    """
    Validate student location with detailed response
    
    Returns:
        dict: Validation result with status and distance
    """
    is_valid, distance = is_within_radius(
        student_lat, student_lon,
        sesi_lat, sesi_lon,
        radius_meters
    )
    
    return {
        'valid': is_valid,
        'distance': round(distance, 2),
        'radius': radius_meters,
        'message': 'Location valid' if is_valid else f'Too far from session location ({round(distance, 2)}m > {radius_meters}m)'
    }
