@echo off
mysql -u root -e "UPDATE guyub.users SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3pPVJDZQqPw6Q8/X5hBB8j8WS5Iq' WHERE email = 'admin@guyub.id';"
