from dever00 import PersonagemAnime, Shinobi, Saiyajin

if __name__ == "__main__":

    print("Executando o sistema de personagens de anime...")

    print("\n" + "="*40)
    print("--- Teste de Instanciação  ---")
    try:
        p_abstrato = PersonagemAnime("Fantasma", "Bleach", 1000)
        print("ERRO: Instanciou PersonagemAnime (Isto não deveria acontecer)")
    except TypeError as e:
        print(f"Sucesso: Classe Abstrata 'PersonagemAnime' não pode ser instanciada.")
        print(f"Detalhe do Erro: {e}")
    print("="*40)

    print("\n--- Testes Subclasse SHINOBI  ---")

    s1 = Shinobi("Naruto Uzumaki", 9000, "Konoha", "Rasen-Shuriken")

    s2 = Shinobi("Sasuke Uchiha", 8800, "Konoha")

    print("\n--- Testando Shinobi 1 (Naruto) ---")

    print("-> Testando métodos funcionais (Super):")
    s1.exibir_info() 
    s1.treinar(1000) 
    
    print("\n-> Testando Gets (Super):")
    print(f"Nome (Get): {s1.nome}")
    print(f"Origem (Get): {s1.anime_origem}")
    print(f"Poder (Get): {s1.nivel_poder}")
    print(f"Status (Get): {s1.status}")

    print("\n-> Testando Gets (Sub):")
    print(f"Vila (Get): {s1.vila}")
    print(f"Jutsu (Get): {s1.jutsu_principal}")
    
    print("\n-> Testando métodos funcionais (Sub/Override):")
    s1.tecnica_especial() 
    s1.realizar_missao("S") 

    print("\n-> Testando Setters (Super e Sub):")

    print("Tentando setar poder para -100 (inválido):")
    s1.nivel_poder = -100
    print(f"Poder atual (Get): {s1.nivel_poder}") 

    print("Tentando setar jutsu para '' (inválido):")
    s1.jutsu_principal = ""
    print(f"Jutsu atual (Get): {s1.jutsu_principal}")

    s1.status = "Hokage"
    print(f"Novo Status (Get): {s1.status}")


    print("\n--- Testando Shinobi 2 (Sasuke - 3 args) ---")
    s2.exibir_info()
    print(f"Jutsu (Default): {s2.jutsu_principal}") 
    s2.jutsu_principal = "Chidori" 
    s2.tecnica_especial()

    print("\n" + "="*40)
    print("\n--- Testes Subclasse SAIYAJIN  ---")


    saj1 = Saiyajin("Goku", 10000, 7, "Super Saiyajin")

    saj2 = Saiyajin("Vegeta", 9500, 7)

    print("\n--- Testando Saiyajin 1 (Goku) ---")

    print("-> Testando métodos funcionais (Super):")
    saj1.exibir_info() 
    saj1.treinar(5000) 
    
    print("\n-> Testando Gets (Super):")
    print(f"Nome (Get): {saj1.nome}")
    print(f"Poder (Get): {saj1.nivel_poder}")

    print("\n-> Testando Gets (Sub):")
    print(f"Universo (Get): {saj1.universo}")
    print(f"Transformação (Get): {saj1.transformacao_atual}")

    print("\n-> Testando métodos funcionais (Sub/Override):")
    saj1.tecnica_especial() 
    saj1.transformar("Super Saiyajin Blue")

    print("\n-> Testando Setters (Super e Sub):")
    saj1.anime_origem = "Dragon Ball Super" 
    print(f"Novo Anime (Get): {saj1.anime_origem}")
    print(f"Nova Transformação (Get): {saj1.transformacao_atual}")
    print(f"Poder após transformação (Get): {saj1.nivel_poder}")

    print("\n--- Testando Saiyajin 2 (Vegeta - 3 args) ---")
    saj2.exibir_info()
    print(f"Transformação (Default): {saj2.transformacao_atual}") 
    saj2.tecnica_especial()
    saj2.transformar("Super Saiyajin God")
    saj2.exibir_info() 
    print("\n" + "="*40)