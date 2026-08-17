ALTER TABLE permissions
    ADD COLUMN module VARCHAR(100),
    ADD COLUMN action VARCHAR(50);
