#!/bin/bash

# Script para compilar o Timer App

echo "Compilando Timer App..."

# Verificar se o Swift está instalado
if ! command -v swift &> /dev/null; then
    echo "Erro: Swift não está instalado. Por favor, instale o Xcode."
    exit 1
fi

# Compilar
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Compilação bem-sucedida!"
    echo "Executável em: .build/release/TimerApp"
    echo ""
    echo "Para executar: .build/release/TimerApp"
else
    echo "❌ Erro na compilação"
    exit 1
fi

