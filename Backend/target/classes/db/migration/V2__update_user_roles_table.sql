-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Drop the existing user_roles table if it exists
DROP TABLE IF EXISTS user_roles;

-- Create the new user_roles table with the correct structure
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, role),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Migrate existing roles from users table if needed
-- First, ensure the role column exists
SET @dbname = DATABASE();
SET @tablename = 'users';
SET @columnname = 'role';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_schema = @dbname)
      AND (table_name = @tablename)
      AND (column_name = @columnname)
  ) > 0,
  'INSERT INTO user_roles (user_id, role) SELECT id, role FROM users WHERE role IS NOT NULL',
  'SELECT 1'
));

PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
