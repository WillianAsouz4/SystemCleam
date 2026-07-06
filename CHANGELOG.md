# Changelog — Limpeza do Sistema (MyApp)

Registro do que foi feito nesta sessão de trabalho, para referência futura.

## Projeto e build

- Removido `ENABLE_APP_SANDBOX` (estava `YES` sem entitlements) — sob sandbox, o
  macOS redireciona `~/Library/Caches`, `~/Downloads` etc. para o container do
  próprio app, então o scanner nunca via os arquivos reais do usuário.
- Removidos `ENABLE_USER_SELECTED_FILES` e `REGISTER_APP_GROUPS`, que não fazem
  sentido sem sandbox.

## Design da interface (`ContentView.swift` e `Views/`)

- Trocado o layout de cards manuais (cores fixas, cantos arredondados) por
  `Form` com `.formStyle(.grouped)` — o estilo nativo de seções do macOS, que
  se adapta automaticamente a modo claro/escuro.
- `AppColors.swift` perdeu as cores fixas de fundo (`groupedBackground`,
  `secondaryGroupedBackground`), que não reagiam ao modo escuro.
- Cada categoria (Caches, Sobras, Arquivos grandes) virou uma `Section` própria
  com cabeçalho/rodapé nativos.
- Confirmação de "mover para a Lixeira" trocada de `.confirmationDialog` (um
  diálogo de sistema) para um aviso **embutido no próprio painel** — diálogos
  de sistema roubam o foco da janela do `MenuBarExtra`, que fecha
  automaticamente ao perder o foco. Isso também afeta os diálogos de permissão
  de pasta do macOS (Desktop/Documents/Downloads), que fecham a janela da
  mesma forma; a operação em si continua rodando em segundo plano mesmo assim.

## `CleanupScanner.swift`

- **Sobras de apps apagados**: antes listava tudo em `Application Support`,
  `Preferences`, `Containers` e `Saved Application State`, sem checar se o app
  ainda estava instalado. Agora só mostra algo se:
  - o nome tiver formato de bundle ID (`com.algo.app`, precisa ter um ponto);
  - não começar com `com.apple.` (dados internos do sistema nunca são
    "sobra de app apagado");
  - não for o bundle ID do próprio MyApp (evita a app tentar apagar suas
    próprias preferências/estado enquanto roda);
  - não corresponder a nenhum app encontrado em `/Applications`,
    `/System/Applications` ou `~/Applications`.
- **Tamanho em disco**: trocado de tamanho lógico (`fileSizeKey`) para espaço
  realmente alocado no disco (`totalFileAllocatedSizeKey`). Um arquivo esparso
  (ex.: imagem de VM do `com.apple.container`) pode ter um tamanho lógico de
  vários TB mas ocupar poucos GB reais — o app estava reportando o número
  errado.
- **Caches de apps**: também passou a excluir a cache do próprio MyApp.

## `StorageStatus.swift`

- Trocado `FileManager.attributesOfFileSystem(forPath:)` (conta espaço bruto
  em blocos) por `URLResourceValues` com
  `volumeAvailableCapacityForImportantUsageKey` — a mesma métrica que o
  Ajustes do Sistema usa, que desconta espaço purgável (snapshots locais do
  Time Machine, cache reciclável do iCloud). Antes disso, o app mostrava
  ~10 GB a mais de uso do que o Ajustes do Sistema.

## Coisas conhecidas / esperadas (não são bugs)

- Caches voltam a crescer depois de limpar — é normal, apps recriam cache sob
  demanda (Homebrew baixa pacotes de novo, navegadores cacheiam páginas).
  Limpeza de cache é manutenção periódica, não algo definitivo.
- Categoria "Caches de apps" lista cache de tudo (instalado ou não) de
  propósito — cache é sempre seguro de apagar, então não há filtro de "app
  instalado" nela (diferente da categoria de sobras).

## Categorias recolhíveis e progresso em tempo real

- Cada categoria passou a vir **recolhida por padrão**, mostrando só ícone,
  título, contagem "X/Y selecionados" e tamanho total. Expande ao clicar pra
  ver e desmarcar arquivos individuais.
- `CleanupScanner.moveToTrash` agora aceita um callback `onProgress`, chamado
  a cada item processado (`@MainActor` pra evitar erro de isolamento de actor
  ao mexer em estado de UI a partir da task em background).
- `ContentView` mostra, durante a limpeza, uma barra de progresso segmentada +
  contador (`3/12`) + o nome do arquivo sendo movido no momento, em vez de só
  travar num spinner genérico.

## Redesign visual (mockup aprovado em HTML antes de portar)

Antes de mexer no Swift, foi feito um protótipo interativo em HTML/CSS/JS
(refletindo pedido do usuário por algo mais compacto e com barras estilo
bateria/sinal da Apple) pra alinhar o visual sem precisar recompilar o app a
cada ajuste. Depois de aprovado, o visual foi portado pra SwiftUI:

- **`Views/AppColors.swift`**: paleta nova com pares de cor claro/escuro fixos
  (via `NSColor(name:dynamicProvider:)`), em vez de depender só dos materiais
  padrão do `Form`. Cor de destaque (teal `#0F9488`) e cor de perigo (vermelho
  `#D6493C`) fixas nos dois modos; fundo, cards e texto secundário mudam de
  tom entre claro/escuro.
- **`Views/SegmentedProgressBar.swift`**: barra de traços verticais (estilo
  indicador de bateria/sinal da Apple), reaproveitada em três lugares: uso de
  disco geral, proporção de cada categoria dentro do total encontrado, e
  progresso da limpeza.
- **`ContentView.swift`**: trocado `Form`/`.formStyle(.grouped)`/
  `NavigationStack` por um layout `VStack`/`ScrollView` totalmente customizado
  — cabeçalho compacto com botões de ícone, card de armazenamento sem o gauge
  circular (agora é a barra segmentada), linha "Encontrado X / selecionado Y",
  cards de categoria, card de ação com os 3 estados (normal, confirmação,
  progresso), rodapé de segurança em uma linha só.
- **`Views/CleanupCategorySection.swift`**: card recolhível customizado (não
  usa mais `DisclosureGroup`/`Section` nativos do `Form`), com uma
  `SegmentedProgressBar` mini mostrando a proporção da categoria dentro do
  total encontrado.
- **`Views/CleanupItemRow.swift`**: linha de arquivo compacta com checkbox
  circular customizado, sem o card arredondado por item de antes.
- **`MyApp.swift`**: painel do menu bar reduzido de 620×700 para 380×560.
- Removidos por ficarem sem uso: `Views/SafetyPill.swift` (virou um card de
  segurança de uma linha só) e `CleanupCategory.description` (não aparece mais
  nos cards compactos).

## Próximo passo

Testar o novo visual no app de verdade (claro e escuro) e ajustar detalhes de
espaçamento/cor que não baterem exatamente com o esperado.
