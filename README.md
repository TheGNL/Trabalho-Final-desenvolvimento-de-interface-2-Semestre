# 🎮 FlowGames - Portal de Notícias Gamer com IA Integrada

Este projeto foi desenvolvido como Trabalho Final da disciplina de **Desenvolvimento de Interfaces (DI)** do curso de Engenharia de Software.

O objetivo foi criar uma interface moderna, responsiva e acessível para um portal de notícias de jogos, integrando uma funcionalidade avançada de Chatbot com Inteligência Artificial (Minha escolha, não era requerido, nem necessário).

## 🚀 Tecnologias Utilizadas

O projeto foi construído utilizando uma arquitetura **Full Stack** para garantir segurança e performance:

### Front-end (Interface)
* **HTML5 & CSS3:** Estrutura semântica e estilização moderna (incluindo Dark Mode e animações).
* **JavaScript (React):** Utilizado via CDN com Babel para renderização dinâmica de componentes, gerenciamento de estado (`useState`) e efeitos colaterais (`useEffect`) sem a necessidade de *bundlers* complexos.
* **Tailwind CSS:** Para estilização utilitária rápida e responsiva.

### Back-end (Servidor & IA)
* **Python (Flask):** Servidor API responsável por intermediar a comunicação entre o site e a Inteligência Artificial, protegendo as chaves de acesso.
* **Google Gemini AI (Modelo `gemini-2.0-flash`):** LLM (Large Language Model) integrado para atuar como o "Nexus AI", um assistente virtual especialista em games.
* **Bibliotecas:** `flask-cors` para gerenciamento de requisições e `python-dotenv` para segurança de credenciais.

## 💡 Funcionalidades Principais

1.  **Feed de Notícias Dinâmico:** Carrossel interativo e listagem de notícias separadas por categorias (PC, PlayStation, Xbox, eSports).
2.  **Nexus AI (Chatbot):** Um assistente virtual inteligente capaz de responder perguntas sobre lançamentos, lore de jogos e dicas de hardware em tempo real.
3.  **Acessibilidade:** Controle de tamanho de fonte, alto contraste e redução de movimento.
4.  **Modo Escuro:** Implementação nativa de tema dark respeitando as preferências do público gamer.

## 🧠 Desafios e Aprendizados

O desenvolvimento deste projeto apresentou desafios técnicos significativos que foram superados durante a implementação:

### 1. Integração JavaScript Assíncrono (Front-end)
Um dos maiores desafios foi gerenciar o estado da aplicação React pura dentro de um arquivo único. Fazer o **JavaScript** lidar com as requisições assíncronas (`fetch`) para o servidor Python, tratar os erros de conexão (ex: servidor offline) e atualizar a interface do chat em tempo real ("Digitando...") exigiu uma lógica robusta de tratamento de promessas e *feedback* visual para o usuário.

### 2. Conexão com o LLM e Python (Back-end)
A implementação do **Back-end em Python** foi a parte mais complexa da infraestrutura.
* **Versionamento de Modelos:** Houve dificuldade em configurar a biblioteca `google.generativeai` para reconhecer os modelos mais recentes. Foi necessário depurar a lista de modelos disponíveis via script para descobrir que a conta tinha acesso ao `gemini-2.0-flash`, enquanto o código tentava usar versões depreciadas, gerando erros 404.
* **Segurança e CORS:** Configurar o Flask para aceitar requisições locais do navegador (CORS) e garantir que a Chave de API não ficasse exposta no Front-end foi um aprendizado crucial de segurança.

---
Desenvolvido por **[Guilherme neves lourenço]** - 2025.
