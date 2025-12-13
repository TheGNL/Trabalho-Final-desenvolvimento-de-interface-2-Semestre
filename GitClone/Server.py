from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai

app = Flask(__name__)
CORS(app) 

# --- CONFIGURAÇÃO ---
# Lembre-se: Se for subir no GitHub, use variáveis de ambiente ou apague a chave antes!
minha_chave = "Pegar chave no https://aistudio.google.com/api-keys" 
genai.configure(api_key=minha_chave)

model = genai.GenerativeModel('gemini-2.0-flash')

@app.route('/chat', methods=['POST'])
def chat():
    dados = request.json
    mensagem_usuario = dados.get('mensagem')

    if not mensagem_usuario:
        return jsonify({"erro": "Nenhuma mensagem enviada"}), 400

    try:
        # MUDANÇA AQUI: Nova personalidade para o site de notícias
        prompt_sistema = (
            "Você é o 'Nexus AI', um assistente virtual especialista em videogames, "
            "e-sports (principalmente League of Legends) e tecnologia. "
            "Suas respostas devem ser curtas, diretas e com linguagem gamer (mas profissional). "
            f"Responda à pergunta do usuário: {mensagem_usuario}"
        )
        
        response = model.generate_content(prompt_sistema)
        return jsonify({"resposta": response.text})
    
    except Exception as e:
        # --- ADICIONE ESTA LINHA ABAIXO PARA VER O ERRO NO TERMINAL ---
        print(f"ERRO DETALHADO: {e}") 
        # --------------------------------------------------------------
        return jsonify({"erro": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)