CREATE DATABASE tempmon;
USE tempmon;

CREATE TABLE switches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    switch_id VARCHAR(255) NOT NULL,
    ip_address VARCHAR(255) NOT NULL
);