import psycopg2
import sys

# --- CONFIGURAÇÕES DE CONEXÃO COM O BANCO DE DADOS ---
# Altere estes valores para os da sua configuração local
DB_NAME = "SASKE"
DB_USER = "postgres"
DB_PASS = "neves2005"
DB_HOST = "localhost"
DB_PORT = "5432"

def conectar():
    """Estabelece a conexão com o banco de dados PostgreSQL."""
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            host=DB_HOST,
            port=DB_PORT
        )
        return conn
    except psycopg2.OperationalError as e:
        print(f"Erro: Não foi possível conectar ao banco de dados '{DB_NAME}'.")
        print(f"Detalhe do erro: {e}")
        sys.exit(1) # Encerra o script se não conseguir conectar

def executar_consulta(query):
    """Executa uma consulta e retorna todos os resultados."""
    conn = None
    try:
        conn = conectar()
        # O cursor é usado para executar comandos no banco de dados
        with conn.cursor() as cur:
            cur.execute(query)
            # Retorna None se a consulta não produzir linhas (ex: UPDATE, INSERT)
            if cur.description:
                resultados = cur.fetchall()
                return resultados
            return None
    except psycopg2.Error as e:
        print(f"Erro ao executar a consulta: {e}")
        return None
    finally:
        if conn:
            conn.close()

def exibir_menu():
    """Mostra o menu de opções para o usuário."""
    print("\n--- SISTEMA DE CONSULTA DE VENDAS ---")
    print("Qual informação você gostaria de ver?")
    print("1. Qual o produto mais vendido?")
    print("2. Qual a situação do estoque?")
    print("3. Qual o melhor cliente (quem gastou mais)?")
    print("4. Sair")
    return input("Digite o número da sua opção: ")

def main():
    """Função principal que gerencia a interação com o usuário."""
    while True:
        opcao = exibir_menu()

        if opcao == '1':
            print("\nBuscando o produto mais vendido...")
            query = "SELECT produto_mais_vendido();"
            resultado = executar_consulta(query)
            if resultado:
                # resultado será uma lista de tuplas, ex: [('Headset Gamer',)]
                print("-" * 40)
                print(f"🏆 Produto mais vendido: {resultado[0][0]}")
                print("-" * 40)
            else:
                print("Não foi possível obter a informação.")

        elif opcao == '2':
            print("\nVerificando a situação do estoque...")
            query = "SELECT * FROM situacao_estoque();"
            resultados = executar_consulta(query)
            if resultados:
                print("-" * 50)
                # Cabeçalho da tabela
                print(f"{'PRODUTO':<25} | {'ESTOQUE ATUAL':<15} | {'STATUS'}")
                print("-" * 50)
                # Linhas da tabela
                for produto, estoque, status in resultados:
                    print(f"{produto:<25} | {estoque:<15} | {status}")
                print("-" * 50)
            else:
                print("Não foi possível obter a informação.")

        elif opcao == '3':
            print("\nBuscando o melhor cliente...")
            query = "SELECT melhor_cliente();"
            resultado = executar_consulta(query)
            if resultado:
                # resultado será uma lista de tuplas, ex: [('João Silva',)]
                print("-" * 40)
                print(f"⭐ Melhor cliente: {resultado[0][0]}")
                print("-" * 40)
            else:
                print("Não foi possível obter a informação.")

        elif opcao == '4':
            print("Saindo do sistema. Até logo!")
            break

        else:
            print("\nOpção inválida! Por favor, escolha um número de 1 a 4.")
        
        input("\nPressione Enter para continuar...")


# Ponto de entrada do script
if __name__ == "__main__":
    main()