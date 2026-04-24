# Command-only targets.
.PHONY: get clean clean_cache macos m fix_gradle c

# Flutter commands
get: 
	flutter pub get

clean:
	flutter clean
	flutter pub get

clean_cache:
	flutter pub clean
	flutter pub cache clean
	flutter pub get

macos:
	flutter run -d macos

m:
	flutter run -d macos

# Fix Gradle lock issues
fix_gradle:
	./android/gradlew --stop 2>/dev/null; pkill -f "GradleDaemon" 2>/dev/null; rm -rf android/.gradle; echo "Gradle daemons stopped and locks cleaned"

# clear console 
c: 
	clear
