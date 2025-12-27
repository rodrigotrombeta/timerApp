# Configuração no Xcode

Para criar um projeto Xcode completo a partir destes arquivos:

## Passo a passo

1. **Abrir Xcode** e criar um novo projeto:
   - File → New → Project
   - Escolher "macOS" → "App"
   - Nome: "TimerApp"
   - Interface: SwiftUI
   - Language: Swift
   - Não marcar "Use Core Data"

2. **Substituir arquivos**:
   - Deletar o arquivo `ContentView.swift` gerado automaticamente
   - Deletar o arquivo `TimerAppApp.swift` (ou similar)
   - Adicionar os arquivos `TimerApp.swift` e `TimerContentView.swift` ao projeto

3. **Configurar Info.plist** (opcional, para melhor integração):
   - Adicionar `LSUIElement` = `YES` para esconder o app do Dock
   - Isso já está configurado no código com `NSApp.setActivationPolicy(.accessory)`

4. **Compilar e executar**:
   - Pressione ⌘R ou clique em Run
   - O app aparecerá na menu bar

## Notas

- O app não aparecerá no Dock (comportamento desejado para menu bar apps)
- Para fechar o app, clique com botão direito no ícone da menu bar e escolha "Quit"
- Ou use ⌘Q quando o popover estiver aberto

