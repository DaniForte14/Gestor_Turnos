-- Create a procedure to safely drop foreign key if it exists
DROP PROCEDURE IF EXISTS drop_foreign_key_if_exists;
DELIMITER //
CREATE PROCEDURE drop_foreign_key_if_exists()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
    
    -- Drop the foreign key constraint if it exists
    SET @s = CONCAT('ALTER TABLE vehicles DROP FOREIGN KEY fk_vehicle_owner');
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Execute the procedure to drop the foreign key if it exists
CALL drop_foreign_key_if_exists();

-- Drop the procedure as it's no longer needed
DROP PROCEDURE IF EXISTS drop_foreign_key_if_exists;

-- Drop the old user_vehicle_passengers table if it exists
DROP TABLE IF EXISTS user_vehicle_passengers;

-- Create the new join table for the many-to-many relationship
CREATE TABLE IF NOT EXISTS user_vehicle_passengers (
    user_id BIGINT NOT NULL,
    vehicle_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, vehicle_id),
    CONSTRAINT fk_user_vehicle_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_vehicle_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recreate the foreign key for the owner relationship if it doesn't exist
SET @s = (SELECT IF(
    (SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'vehicles'
        AND CONSTRAINT_NAME = 'fk_vehicle_owner') > 0,
    'SELECT 1',
    CONCAT('ALTER TABLE vehicles ADD CONSTRAINT fk_vehicle_owner FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE SET NULL;')));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
