import face_recognition
import numpy as np
import base64
import io
from PIL import Image
from database.db import Database

class FaceService:
    """Service for face recognition operations"""
    
    @staticmethod
    def encode_face_from_image(image_file):
        """
        Generate face encoding from uploaded image
        
        Args:
            image_file: File object or base64 string
            
        Returns:
            tuple: (success: bool, encoding: list or error: str)
        """
        try:
            # Load image
            if isinstance(image_file, str):
                # Base64 string
                image_data = base64.b64decode(image_file.split(',')[1] if ',' in image_file else image_file)
                image = Image.open(io.BytesIO(image_data))
                image_array = np.array(image)
            else:
                # File object
                image = face_recognition.load_image_file(image_file)
                image_array = image
            
            # Find faces in image
            face_locations = face_recognition.face_locations(image_array)
            
            if len(face_locations) == 0:
                return False, "No face detected in image"
            
            if len(face_locations) > 1:
                return False, "Multiple faces detected. Please use image with single face"
            
            # Generate encoding
            face_encodings = face_recognition.face_encodings(image_array, face_locations)
            
            if len(face_encodings) == 0:
                return False, "Could not generate face encoding"
            
            encoding = face_encodings[0].tolist()
            
            return True, encoding
            
        except Exception as e:
            return False, f"Error processing image: {str(e)}"
    
    @staticmethod
    def save_face_encoding(nim, encoding):
        """
        Save face encoding to database
        
        Args:
            nim: Student NIM
            encoding: Face encoding array
            
        Returns:
            bool: Success status
        """
        try:
            # Convert encoding to JSON string
            import json
            encoding_json = json.dumps(encoding)
            
            # Update mahasiswa table
            query = """
                UPDATE mahasiswa 
                SET face_descriptor = %s, face_registered = 1, updated_at = NOW()
                WHERE nim = %s
            """
            Database.execute_query(query, (encoding_json, nim), commit=True)
            
            return True
            
        except Exception as e:
            print(f"Error saving face encoding: {e}")
            return False
    
    @staticmethod
    def verify_face(nim, image_file, tolerance=0.6):
        """
        Verify face against stored encoding
        
        Args:
            nim: Student NIM
            image_file: Uploaded image file
            tolerance: Recognition tolerance (lower = more strict)
            
        Returns:
            tuple: (success: bool, confidence: float or error: str)
        """
        try:
            # Get stored encoding
            query = "SELECT face_descriptor FROM mahasiswa WHERE nim = %s AND face_registered = 1"
            result = Database.execute_query(query, (nim,), fetch_one=True)
            
            if not result or not result['face_descriptor']:
                return False, "Face not registered for this student"
            
            # Parse stored encoding
            import json
            stored_encoding = np.array(json.loads(result['face_descriptor']))
            
            # Get encoding from new image
            success, new_encoding = FaceService.encode_face_from_image(image_file)
            
            if not success:
                return False, new_encoding  # new_encoding contains error message
            
            new_encoding_array = np.array(new_encoding)
            
            # Compare faces
            distance = face_recognition.face_distance([stored_encoding], new_encoding_array)[0]
            is_match = distance <= tolerance
            
            # Calculate confidence score (inverse of distance)
            confidence = max(0, min(100, (1 - distance) * 100))
            
            if is_match:
                return True, round(confidence, 2)
            else:
                return False, f"Face does not match (confidence: {round(confidence, 2)}%)"
            
        except Exception as e:
            return False, f"Error verifying face: {str(e)}"
    
    @staticmethod
    def get_registered_status(nim):
        """Check if student has registered face"""
        try:
            query = "SELECT face_registered FROM mahasiswa WHERE nim = %s"
            result = Database.execute_query(query, (nim,), fetch_one=True)
            
            if result:
                return result['face_registered'] == 1
            return False
            
        except Exception as e:
            print(f"Error checking face registration: {e}")
            return False
