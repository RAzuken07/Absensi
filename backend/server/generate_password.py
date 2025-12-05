import bcrypt

# Generate hashed password untuk '123456'
password = '123456'
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
print(f"Hashed password for '{password}':")
print(hashed.decode('utf-8'))

# SQL Update statements
print("\n" + "="*60)
print("SQL UPDATE STATEMENTS:")
print("="*60)
print(f"""
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = 'admin';
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = 'dosen1';
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = 'dosen2';
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = '220101001';
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = '220101002';
UPDATE users SET password = '{hashed.decode('utf-8')}' WHERE username = '220101003';
""")

print("\nCopy SQL di atas dan jalankan di phpMyAdmin!")
