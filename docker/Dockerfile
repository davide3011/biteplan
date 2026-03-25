# ── Android SDK + Node (ambiente di build) ────────────────────────────────────
FROM node:20-slim

# Dipendenze di sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk-headless \
    wget \
    unzip \
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

# ── Runtime: dist/ viene montato come volume dall'host ────────────────────────
# build.sh esegue: docker run -v ./dist:/app/dist ...
# Qui cap sync copia dist/ in android/assets, poi Gradle builda l'APK

CMD npx cap sync android && \
    cd android && chmod +x gradlew && ./gradlew assembleDebug --no-daemon && \
    cp app/build/outputs/apk/debug/app-debug.apk /output/biteplan.apk && \
    echo "APK generato: /output/biteplan.apk"
