#!/bin/bash

# Script para criar o ícone .icns do Timer App

echo "Criando ícone do app..."

ICON_DIR="TimerApp.iconset"
ICON_NAME="AppIcon.icns"

# Remover ícone antigo se existir
rm -rf "$ICON_DIR" "$ICON_NAME"

# Criar diretório do iconset
mkdir -p "$ICON_DIR"

# Criar um script Swift temporário para gerar as imagens do ícone
cat > /tmp/create_icon.swift <<'EOF'
import AppKit
import Foundation

let sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

guard let image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer") else {
    print("Erro: Não foi possível criar a imagem do ícone")
    exit(1)
}

let iconDir = "TimerApp.iconset"

for (size, filename) in sizes {
    let resized = NSImage(size: NSSize(width: size, height: size))
    resized.lockFocus()
    
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    
    resized.unlockFocus()
    
    guard let tiffData = resized.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Erro ao criar PNG para tamanho \(size)")
        continue
    }
    
    let filePath = "\(iconDir)/\(filename)"
    try? pngData.write(to: URL(fileURLWithPath: filePath))
    print("Criado: \(filename) (\(size)x\(size))")
}

print("✅ Ícones criados com sucesso!")
EOF

# Executar o script Swift
cd "$(dirname "$0")"
swift /tmp/create_icon.swift

if [ $? -eq 0 ]; then
    # Criar o arquivo .icns usando iconutil
    iconutil -c icns "$ICON_DIR" -o "$ICON_NAME"
    
    if [ $? -eq 0 ]; then
        echo "✅ Ícone criado: $ICON_NAME"
        rm -rf "$ICON_DIR"
        rm -f /tmp/create_icon.swift
    else
        echo "❌ Erro ao criar .icns"
        exit 1
    fi
else
    echo "❌ Erro ao criar imagens do ícone"
    exit 1
fi

