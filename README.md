# SystemCleam

Um app de menu bar para macOS, simples e nativo, que ajuda a liberar espaço em
disco: encontra cache de apps, sobras de apps já desinstalados e arquivos
grandes esquecidos em Downloads/Desktop/Documents.

Feito como projeto de hobby em SwiftUI, sem sandbox, sem telemetria, sem
dependências externas.

## Funcionalidades

- **Uso de disco**: mostra o espaço livre real (mesma métrica do Ajustes do
  Sistema, descontando espaço purgável).
- **Cache de apps**: lista o conteúdo de `~/Library/Caches`.
- **Sobras de apps desinstalados**: identifica arquivos de configuração e
  estado de apps que não estão mais instalados (checando bundle ID contra
  `/Applications`, `/System/Applications` e `~/Applications`).
- **Arquivos grandes**: encontra arquivos acima de 500 MB em
  Downloads, Desktop e Documents.
- Seleção item a item antes de mover para a Lixeira, com progresso em tempo
  real.

Tudo roda dentro da pasta do usuário atual (`~/Library/...`) — o app nunca
mexe em dados de sistema ou de outros usuários.

## Build

Requer Xcode. Abra `SystemCleam.xcodeproj` e rode com `⌘R` (Product > Run).
Por ser um app de menu bar, ele aparece na barra de menu do macOS, não em uma
janela comum.

## Estrutura do projeto

```
SystemCleam/
├── MyApp.swift                 # entry point / painel do menu bar
├── ContentView.swift           # layout principal
├── Models/
│   ├── CleanupModels.swift
│   └── StorageStatus.swift
├── Services/
│   └── CleanupScanner.swift    # varredura e limpeza de arquivos
└── Views/
    ├── AppColors.swift
    ├── CleanupCategorySection.swift
    ├── CleanupItemRow.swift
    ├── SegmentedProgressBar.swift
    └── StorageStatusPanel.swift
```

Veja `AGENTS.md` para convenções de código e `CHANGELOG.md` para o histórico
de decisões técnicas do projeto.

## Roadmap

Ideias de melhorias futuras estão em [ROADMAP.md](ROADMAP.md).

## Contribuindo

Projeto de hobby, contribuições são bem-vindas. Abra uma issue ou PR.

## Licença

MIT — veja [LICENSE](LICENSE).
