start:
	./mvnw spring-boot:run

# Migration
migration:
	@read -p "Migration name: " name; ./make-migration.sh $$name
migrate:
	@echo "Running database migrations..."
	@flyway migrate && echo "Migrations applied successfully." || echo "Migration failed. Run 'flyway repair' if checksum mismatch."
repair:
	@echo "Repairing flyway schema history..."
	@flyway repair && echo "Repair complete. Run 'make migrate' to apply migrations."

seed:
	psql -U postgres -d r99_shop_db -c "TRUNCATE TABLE user_role, role_permission, users, permissions, roles RESTART IDENTITY CASCADE;"
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/roles.sql
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/permissions.sql
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/role_permission.sql
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/users.sql
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/user_role.sql

seed-test: seed
	psql -U postgres -d r99_shop_db -f src/main/resources/db/seed/test_ui.sql
