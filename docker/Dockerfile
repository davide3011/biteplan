# ── Android SDK + Node (ambiente di build) ────────────────────────────────────
# eclipse-temurin:21 (Adoptium) su Ubuntu Jammy include Java 21
FROM eclipse-temurin:21-jdk-jammy

# Installa Node.js 20 e dipendenze di sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
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

# ── Icone Android da assets/icon-only.png ────────────────────────────────────
COPY assets/ ./assets/
RUN npx @capacitor/assets generate --android

# Fix kotlin-stdlib duplicate class conflict (stdlib 1.8+ already includes jdk7/jdk8)
RUN printf '\nsubprojects {\n    configurations.all {\n        resolutionStrategy {\n            force "org.jetbrains.kotlin:kotlin-stdlib:1.8.22"\n            force "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22"\n            force "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22"\n        }\n    }\n}\n' >> android/build.gradle

# ── Runtime: dist/ viene montato come volume dall'host ────────────────────────
# build.sh esegue: docker run -v ./dist:/app/dist ...
# Qui cap sync copia dist/ in android/assets, poi Gradle builda l'APK

CMD npx cap sync android && \
    cd android && chmod +x gradlew && ./gradlew assembleDebug --no-daemon && \
    cp app/build/outputs/apk/debug/app-debug.apk /app/dist/biteplan.apk && \
    echo "APK generato: /app/dist/biteplan.apk"
