# ICCRaiderGuide

**ICCRG (ICC Raider Guide)** é um AddOn leve, modular e responsivo desenvolvido para **World of Warcraft: Wrath of the Lich King (3.3.5a)**. O objetivo do projeto é fornecer um guia prático de táticas e anúncios rápidos no chat para todos os 12 chefes da raid **Icecrown Citadel (ICC)**, facilitando a vida de Raid Leaders, Tanks e jogadores em geral.

---

## ✨ Funcionalidades

* 📜 **Táticas Completas & Resumos**: Conteúdo dividido por dificuldade (**10N, 10H, 25N, 25H**).
* 🌐 **Suporte Multi-idioma**: Alternância instantânea entre **Português (PT)** e **Inglês (EN)** com salvamento de preferência.
* 📢 **Anúncio Dinâmico no Chat**: Botão para enviar resumos de táticas diretamente no canal apropriado (`/raid`, `/rw`, `/party` ou `/say`).
* 🗺️ **Botão Interativo no Minimapa**: Ícone arrastável ao redor do minimapa com efeito tátil ao clicar.
* 📐 **Interface Responsiva**: Janela integrada ao estilo clássico da UI do WoW com rolagem fluida e suporte a redimensionamento.
* 🧱 **Arquitetura Modular**: Estrutura de dados separada por chefe na pasta `BossData/`, facilitando edições e manutenções futuras.

---

## 📁 Estrutura do Projeto

```text
ICCRaiderGuide/
├── ICCRaiderGuide.toc                       # Registro do AddOn e ordem de carregamento
├── ICCRaiderGuide.lua               # Código principal (Interface, Minimapa e Comandos)
├── ICCRaiderGuide.xml              # Estrutura XML da janela principal
└── BossData/
    ├── BossData_Core.lua           # Inicialização das tabelas e ordem dos chefes
    ├── Marrowgar.lua
    ├── Deathwhisper.lua
    ├── Gunship.lua
    ├── Saurfang.lua
    ├── Festergut.lua
    ├── Rotface.lua
    ├── ProfessorPutricide.lua
    ├── BloodPrince.lua
    ├── BloodQueen.lua
    ├── Valithria.lua
    ├── Sindragosa.lua
    └── LichKing.lua
