# Command-only targets.
.PHONY: get clean clean_cache build b macos m android_release ar ios_release ir windows_release wr fix_gradle c

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

build:
	dart run build_runner build --delete-conflicting-outputs

b:
	dart run build_runner build --delete-conflicting-outputs

macos:
	flutter run -d macos -t lib/main_development.dart

m:
	flutter run -d macos -t lib/main_development.dart

android_release:
	flutter build apk --release --flavor production -t lib/main_production.dart

ar:
	flutter build apk --release --flavor production -t lib/main_production.dart

ios_release:
	flutter build ipa --release -t lib/main_production.dart --export-method development

ir:
	flutter build ipa --release -t lib/main_production.dart --export-method development

windows_release:
	flutter build windows --release -t lib/main_production.dart

wr:
	flutter build windows --release -t lib/main_production.dart

# Fix Gradle lock issues
fix_gradle:
	./android/gradlew --stop 2>/dev/null; pkill -f "GradleDaemon" 2>/dev/null; rm -rf android/.gradle; echo "Gradle daemons stopped and locks cleaned"

# clear console 
c: 
	clear


# Auto export
ex:
	./ff auto-export

# Build runner
bb:
	dart run build_runner build