# 🎮 FlowGames - Portal de Notícias Gamer com IA Integrada

Este projeto foi desenvolvido como **Trabalho Final** da disciplina de **Desenvolvimento de Interfaces** (2º Semestre/2025) do curso de **Engenharia de Software** no **CEUB**.

O objetivo foi criar uma *Single Page Application* (SPA) moderna, responsiva e acessível, focada na experiência do usuário (UX) e integrando uma Inteligência Artificial generativa via API.

---

## 🚀 Funcionalidades Principais

### 1. Interface e UX
* **Design Responsivo:** Layout adaptável para Mobile, Tablet e Desktop usando **Tailwind CSS**.
* **Carrossel Interativo:** Destaques das principais notícias com transições automáticas.
* **Dark Mode (Modo Escuro):** Alternância de tema para conforto visual (padrão da indústria gamer).
* **Feed Categorizado:** Filtragem de notícias por plataforma (PC, PlayStation, Xbox, Nintendo, eSports).

### 2. 🤖 Nexus AI (Chatbot Inteligente)
Diferencial técnico do projeto: um assistente virtual integrado que responde dúvidas sobre jogos em tempo real.
* **Backend:** Desenvolvido em **Python (Flask)**.
* **Cérebro:** Utiliza a API do **Google Gemini (gemini-2.0-flash)**.
* *Nota: A IA requer o servidor Python rodando localmente.*

### 3. ♿ Acessibilidade (WCAG)
Painel exclusivo de configurações para inclusão digital:
* Aumento de fonte.
* Modo de Alto Contraste.
* Redução de animações (Reduce Motion).
* Elementos semânticos e navegação via teclado.

---

## 🛠️ Tecnologias Utilizadas

**Front-end:**
* **HTML5 & CSS3:** Estrutura semântica.
* **React (v18):** Utilizado via CDN (sem build step) para gerenciamento de estados e componentes.
* **Babel:** Para transpilação de JSX no navegador.
* **Tailwind CSS:** Framework utilitário para estilização rápida.

**Back-end:**
* **Python:** Linguagem do servidor.
* **Flask:** Micro-framework para criar a API do chat.
* **Google Generative AI:** Integração com LLM (Large Language Model).

---

## 📦 Como Acessar o Projeto

### Opção 1: Visualização Online (GitHub Pages)
Acesse a interface visual do projeto diretamente pelo navegador:
🔗 **[Clique aqui para acessar o FlowGames](https://thegnl.github.io/Trabalho-Final-desenvolvimento-de-interface-2-Semestre/GitClone/)**

> **Aviso:** Na versão online (GitHub Pages), o Chatbot **Nexus AI** estará desativado, pois ele depende do servidor Python (Backend). Apenas a interface visual funcionará.

