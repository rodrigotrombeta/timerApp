#!/bin/bash

# Script para criar um bundle .app do Timer App

echo "Criando bundle .app do Timer App..."

# Verificar se o executável existe
if [ ! -f ".build/release/TimerApp" ]; then
    echo "❌ Erro: Executável não encontrado. Execute ./build.sh primeiro."
    exit 1
fi

# Criar ícone se não existir
if [ ! -f "AppIcon.icns" ]; then
    echo "Ícone não encontrado. Criando ícone..."
    ./create_icon.sh
fi

# Nome do app
APP_NAME="TimerApp.app"
APP_DIR="$APP_NAME"

# Remover bundle antigo se existir
if [ -d "$APP_DIR" ]; then
    echo "Removendo bundle antigo..."
    rm -rf "$APP_DIR"
fi

# Criar estrutura do bundle
echo "Criando estrutura do bundle..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copiar executável
echo "Copiando executável..."
cp ".build/release/TimerApp" "$APP_DIR/Contents/MacOS/TimerApp"
chmod +x "$APP_DIR/Contents/MacOS/TimerApp"

# Copiar ícone se existir
if [ -f "AppIcon.icns" ]; then
    echo "Copiando ícone..."
    cp "AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

# Criar Info.plist
echo "Criando Info.plist..."
cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>TimerApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.timer.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>TimerApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "✅ Bundle criado com sucesso: $APP_DIR"
echo ""
echo "Para instalar, execute:"
echo "  cp -R $APP_DIR /Applications/"
echo ""
echo "Ou arraste $APP_DIR para a pasta Applications no Finder."

