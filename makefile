initialize: clean get slang generate ;\


clean:
	@echo "Cleaning the project..." ; \
	fvm flutter clean ;\

get:
	@echo "Running Flutter pub get..." ;\
	fvm flutter pub get ; \

slang:
	@echo "Running Flutter slang..." ;\
	fvm dart run slang ; \

generate: 
	fvm flutter pub get ;\
	fvm flutter pub run build_runner build --delete-conflicting-outputs ; \

run:
	@echo "Running the app..." ; \
	$(MAKE) generate ; \
	fvm flutter run -t lib/main.dart ; \