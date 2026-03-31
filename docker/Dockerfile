# ── Android SDK + Node (ambiente di build) ────────────────────────────────────
# eclipse-temurin:21 (Adoptium) su Ubuntu Jammy include Java 21
FROM eclipse-temurin:21-jdk-jammy

# Installa Node.js 20 e dipendenze di sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    imagemagick \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ── Android SDK ─────────────────────────────────────────────────────────────────
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
         -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    mv /tmp/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses > /dev/null && \
    sdkmanager \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0"

# ── Progetto (solo dipendenze npm, senza sorgenti) ────────────────────────────
WORKDIR /app

COPY package*.json ./
RUN npm ci

# ── Capacitor config ──────────────────────────────────────────────────────────
RUN cat > capacitor.config.json <<'EOF'
{
  "appId": "com.davide.biteplan",
  "appName": "BitePlan",
  "webDir": "dist",
  "server": {
    "androidScheme": "https"
  }
}
EOF

# ── Installa Capacitor e prepara la piattaforma Android ───────────────────────
RUN npm install @capacitor/core @capacitor/cli @capacitor/android --save

RUN npx cap add android

# ── Permessi Android ──────────────────────────────────────────────────────────
RUN sed -i 's|</manifest>|    <uses-permission android:name="android.permission.CAMERA" />\n</manifest>|' \
    android/app/src/main/AndroidManifest.xml

# ── Versione da package.json → android/app/build.gradle ──────────────────────
RUN node -e "\
      const v = require('./package.json').version; \
      const [a,b,c] = v.split('.').map(Number); \
      const vc = a*10000 + b*100 + c; \
      const fs = require('fs'); \
      let g = fs.readFileSync('android/app/build.gradle','utf8'); \
      g = g.replace(/versionCode \d+/, 'versionCode '+vc); \
      g = g.replace(/versionName \"[^\"]*\"/, 'versionName \"'+v+'\"'); \
      fs.writeFileSync('android/app/build.gradle', g); \
    "

# ── Icone Android da assets/icon-only.png (via ImageMagick) ─────────────────
COPY assets/ ./assets/
RUN rm -rf android/app/src/main/res/mipmap-anydpi-v26 && \
    for d in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do \
      dest=android/app/src/main/res/mipmap-${d%:*}; \
      convert assets/icon-only.png -resize ${d#*:}x${d#*:} $dest/ic_launcher.png; \
      cp $dest/ic_launcher.png $dest/ic_launcher_round.png; \
    done

# Fix kotlin-stdlib duplicate class conflict (stdlib 1.8+ already includes jdk7/jdk8)
RUN printf '\nsubprojects {\n    configurations.all {\n        resolutionStrategy {\n            force "org.jetbrains.kotlin:kotlin-stdlib:1.8.22"\n            force "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22"\n            force "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22"\n        }\n    }\n}\n' >> android/build.gradle

# ── Runtime: dist/ e (opzionale) keystore montati come volumi dall'host ───────
# build.sh esegue: docker run -v ./dist:/app/dist ...
# Con --release: aggiunge -e BUILD_TYPE=release -v biteplan.jks:/app/biteplan.jks:ro
# BUILD_TYPE=release → assembleRelease + zipalign + apksigner
# BUILD_TYPE vuoto   → assembleDebug (default)

CMD npx cap sync android && \
    cd android && chmod +x gradlew && \
    if [ "$BUILD_TYPE" = "release" ]; then \
      ./gradlew assembleRelease --no-daemon && \
      $ANDROID_HOME/build-tools/34.0.0/zipalign -v 4 \
        app/build/outputs/apk/release/app-release-unsigned.apk \
        /tmp/aligned.apk && \
      $ANDROID_HOME/build-tools/34.0.0/apksigner sign \
        --ks /app/biteplan.jks \
        --ks-key-alias biteplan \
        --ks-pass pass:$KEYSTORE_PASS \
        --key-pass pass:$KEY_PASS \
        --out /app/dist/biteplan.apk \
        /tmp/aligned.apk && \
      echo "APK release firmato: /app/dist/biteplan.apk"; \
    else \
      ./gradlew assembleDebug --no-daemon && \
      cp app/build/outputs/apk/debug/app-debug.apk /app/dist/biteplan.apk && \
      echo "APK debug: /app/dist/biteplan.apk"; \
    fi
