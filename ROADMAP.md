# Roadmap

Ideias de melhorias futuras, sem prazo definido — projeto de hobby.
Contribuições nessas frentes são bem-vindas.

## Features

- **Cache de sistema** (`/Library/Caches`): categoria opcional (desmarcada por
  padrão), pedindo autenticação de admin só na hora de mover pra Lixeira.
  `/System/Library/Caches` fica de fora por ser protegido pelo SIP.
- **Agendamento**: varredura automática periódica com notificação de quanto
  espaço dá pra liberar.
- **Lista de exclusão**: usuário marcar pastas/apps que nunca devem aparecer
  na varredura.
- **Duplicados**: detectar arquivos duplicados em Downloads/Desktop.
- **Histórico**: registrar espaço liberado ao longo do tempo.
- **Ícone dinâmico na menu bar**: mudar de acordo com espaço liberável
  disponível.
- **Localização**: `Localizable.strings` para PT-BR/EN (hoje a UI e os
  comentários já são majoritariamente PT-BR).

## Qualidade / infra

- Testes com Swift Testing para `CleanupScanner`, especialmente
  `isOrphanedAppLeftover` e o cálculo de tamanho em disco.
- GitHub Actions rodando `xcodebuild` a cada PR.
