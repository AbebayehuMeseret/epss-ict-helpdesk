-- EPSS ICT Helpdesk & Management System
-- Complete Database Schema
-- MySQL 8.0+

-- ============================================================================
-- 1. ROLES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL UNIQUE,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. PERMISSIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `module` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. ROLE PERMISSIONS JUNCTION TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` INT NOT NULL,
  `permission_id` INT NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. DEPARTMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `departments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `code` VARCHAR(20) UNIQUE,
  `manager_id` INT,
  `cost_center` VARCHAR(50),
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_status` (`status`),
  INDEX `idx_manager_id` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `employee_id` VARCHAR(50) UNIQUE NOT NULL,
  `username` VARCHAR(50) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20),
  `department_id` INT,
  `position` VARCHAR(100),
  `role_id` INT NOT NULL,
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active',
  `last_login` DATETIME,
  `failed_attempts` INT DEFAULT 0,
  `locked_until` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE RESTRICT,
  INDEX `idx_username` (`username`),
  INDEX `idx_email` (`email`),
  INDEX `idx_employee_id` (`employee_id`),
  INDEX `idx_role_id` (`role_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. SUPPORT TYPES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `support_types` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. TICKETS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tickets` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_number` VARCHAR(50) UNIQUE NOT NULL,
  `requester_id` INT NOT NULL,
  `department_id` INT,
  `support_type_id` INT NOT NULL,
  `priority` ENUM('Low', 'Normal', 'High', 'Critical') DEFAULT 'Normal',
  `subject` VARCHAR(255) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `location` VARCHAR(255),
  `assigned_to` INT,
  `status` ENUM('New', 'Acknowledged', 'Assigned', 'In Progress', 'Pending', 'Resolved', 'Closed', 'Cancelled', 'Reopened') DEFAULT 'New',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `acknowledged_at` DATETIME,
  `assigned_at` DATETIME,
  `started_at` DATETIME,
  `resolved_at` DATETIME,
  `closed_at` DATETIME,
  `reopened_at` DATETIME,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`requester_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`support_type_id`) REFERENCES `support_types`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_ticket_number` (`ticket_number`),
  INDEX `idx_status` (`status`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_requester_id` (`requester_id`),
  INDEX `idx_assigned_to` (`assigned_to`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_support_type_id` (`support_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. TICKET STATUS HISTORY TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `ticket_status_history` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `old_status` VARCHAR(50),
  `new_status` VARCHAR(50) NOT NULL,
  `changed_by` INT NOT NULL,
  `reason` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`changed_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX `idx_ticket_id` (`ticket_id`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 9. TICKET ASSIGNMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `ticket_assignments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `assigned_to` INT NOT NULL,
  `assigned_by` INT NOT NULL,
  `assignment_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `acceptance_date` DATETIME,
  `status` ENUM('Pending', 'Accepted', 'Rejected') DEFAULT 'Pending',
  `notes` TEXT,
  FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`assigned_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX `idx_ticket_id` (`ticket_id`),
  INDEX `idx_assigned_to` (`assigned_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 10. TICKET COMMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `ticket_comments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `author_id` INT NOT NULL,
  `comment` LONGTEXT NOT NULL,
  `is_internal` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX `idx_ticket_id` (`ticket_id`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 11. TICKET ATTACHMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `ticket_attachments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `uploaded_by` INT NOT NULL,
  `filename` VARCHAR(255) NOT NULL,
  `original_filename` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(255) NOT NULL,
  `file_size` INT,
  `file_type` VARCHAR(50),
  `mime_type` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX `idx_ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 12. TICKET RESOLUTION TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `ticket_resolutions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL UNIQUE,
  `resolved_by` INT NOT NULL,
  `root_cause` TEXT,
  `action_taken` LONGTEXT,
  `resolution_notes` LONGTEXT,
  `recommendation` TEXT,
  `resolved_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX `idx_ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 13. NOTIFICATIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `notification_type` VARCHAR(50) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `related_entity_type` VARCHAR(50),
  `related_entity_id` INT,
  `is_read` BOOLEAN DEFAULT FALSE,
  `read_at` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 14. NETWORK DEVICES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `network_devices` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `device_name` VARCHAR(100) NOT NULL UNIQUE,
  `device_type` ENUM('Router', 'Switch', 'Firewall', 'Server', 'Access Point', 'Printer', 'UPS', 'CCTV', 'Other') NOT NULL,
  `ip_address` VARCHAR(15) NOT NULL UNIQUE,
  `mac_address` VARCHAR(17),
  `hostname` VARCHAR(100),
  `location` VARCHAR(255),
  `building` VARCHAR(100),
  `floor` VARCHAR(50),
  `room` VARCHAR(50),
  `department_id` INT,
  `vendor` VARCHAR(100),
  `model` VARCHAR(100),
  `serial_number` VARCHAR(100),
  `description` TEXT,
  `monitoring_enabled` BOOLEAN DEFAULT TRUE,
  `status` ENUM('UP', 'DOWN', 'UNKNOWN') DEFAULT 'UNKNOWN',
  `last_checked` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE SET NULL,
  INDEX `idx_ip_address` (`ip_address`),
  INDEX `idx_status` (`status`),
  INDEX `idx_monitoring_enabled` (`monitoring_enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 15. NETWORK MONITORING LOGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `network_monitoring_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `device_id` INT NOT NULL,
  `status` ENUM('UP', 'DOWN', 'UNKNOWN') NOT NULL,
  `response_time` INT,
  `checked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`device_id`) REFERENCES `network_devices`(`id`) ON DELETE CASCADE,
  INDEX `idx_device_id` (`device_id`),
  INDEX `idx_checked_at` (`checked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 16. NETWORK OUTAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `network_outages` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `device_id` INT NOT NULL,
  `outage_start` DATETIME NOT NULL,
  `outage_end` DATETIME,
  `duration_minutes` INT,
  `reason` TEXT,
  `impact` TEXT,
  `resolved_by` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`device_id`) REFERENCES `network_devices`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_device_id` (`device_id`),
  INDEX `idx_outage_start` (`outage_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 17. REPORTING PERIODS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `reporting_periods` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `quarter_name` VARCHAR(50) NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `fiscal_year` INT NOT NULL,
  `description` TEXT,
  `status` ENUM('Active', 'Closed', 'Archived') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_period` (`quarter_name`, `fiscal_year`),
  INDEX `idx_fiscal_year` (`fiscal_year`),
  INDEX `idx_start_date` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 18. KPI METRICS TABLE (calculated from operational data)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `kpi_metrics` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `reporting_period_id` INT NOT NULL,
  `support_type_id` INT NOT NULL,
  `department_id` INT,
  `technician_id` INT,
  `total_requests` INT DEFAULT 0,
  `completed_requests` INT DEFAULT 0,
  `pending_requests` INT DEFAULT 0,
  `completion_rate` DECIMAL(5,2),
  `avg_response_time_minutes` INT,
  `avg_resolution_time_minutes` INT,
  `sla_compliance_rate` DECIMAL(5,2),
  `reopened_count` INT DEFAULT 0,
  `critical_count` INT DEFAULT 0,
  `overdue_count` INT DEFAULT 0,
  `calculated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`reporting_period_id`) REFERENCES `reporting_periods`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`support_type_id`) REFERENCES `support_types`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`technician_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  UNIQUE KEY `unique_kpi` (`reporting_period_id`, `support_type_id`, `department_id`, `technician_id`),
  INDEX `idx_reporting_period_id` (`reporting_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 19. SLA CONFIGURATION TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `sla_config` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `priority` ENUM('Low', 'Normal', 'High', 'Critical') NOT NULL UNIQUE,
  `response_sla_minutes` INT NOT NULL,
  `resolution_sla_minutes` INT NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 20. BUSINESS HOURS CONFIGURATION TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `business_hours_config` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `monday_start` TIME,
  `monday_end` TIME,
  `tuesday_start` TIME,
  `tuesday_end` TIME,
  `wednesday_start` TIME,
  `wednesday_end` TIME,
  `thursday_start` TIME,
  `thursday_end` TIME,
  `friday_start` TIME,
  `friday_end` TIME,
  `saturday_start` TIME,
  `saturday_end` TIME,
  `sunday_start` TIME,
  `sunday_end` TIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 21. HOLIDAYS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `holidays` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `holiday_date` DATE NOT NULL,
  `holiday_name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 22. AUDIT LOGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT,
  `action` VARCHAR(100) NOT NULL,
  `module` VARCHAR(50) NOT NULL,
  `record_id` INT,
  `record_type` VARCHAR(50),
  `description` TEXT NOT NULL,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `changes_before` JSON,
  `changes_after` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_module` (`module`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 23. SYSTEM SETTINGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `setting_key` VARCHAR(100) NOT NULL UNIQUE,
  `setting_value` LONGTEXT,
  `data_type` VARCHAR(20),
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 24. EMAIL CONFIGURATION TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `email_config` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `smtp_host` VARCHAR(255),
  `smtp_port` INT,
  `smtp_username` VARCHAR(255),
  `smtp_password` VARCHAR(255),
  `from_email` VARCHAR(255),
  `from_name` VARCHAR(255),
  `enabled` BOOLEAN DEFAULT FALSE,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 25. SESSIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` VARCHAR(255) PRIMARY KEY,
  `user_id` INT,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `expires_at` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

ALTER TABLE `tickets` ADD FULLTEXT INDEX `ft_subject_description` (`subject`, `description`);
ALTER TABLE `ticket_comments` ADD FULLTEXT INDEX `ft_comment` (`comment`);
ALTER TABLE `users` ADD INDEX `idx_department_id` (`department_id`);
ALTER TABLE `tickets` ADD INDEX `idx_department_id` (`department_id`);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
