# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are up-to-date (run again in case dependencies changed).
RUN dart pub get
RUN dart compile exe bin/flutter_telegram.dart -o bin/flutter_telegram

# Build minimal serving image from scratch with only compiled server binary
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/flutter_telegram /app/bin/

# Expose the port (optional; if your Dart app needs to expose one)
EXPOSE 8080

# Start the app
CMD ["/app/bin/flutter_telegram"]
