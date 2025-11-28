from abc import ABC, abstractmethod

class PersonagemAnime(ABC):
    
    def __init__(self, nome, anime_origem, nivel_poder, status='Vivo'):
        self.__nome = nome
        self.__anime_origem = anime_origem
        self.__nivel_poder = nivel_poder
        self.__status = status
        
        if self.__nivel_poder < 0:
            self.__nivel_poder = 0

    @property
    def nome(self):
        return self.__nome

    @property
    def anime_origem(self):
        return self.__anime_origem

    @property
    def nivel_poder(self):
        return self.__nivel_poder

    @property
    def status(self):
        return self.__status

    @nome.setter
    def nome(self, novo_nome):
        self.__nome = novo_nome

    @anime_origem.setter
    def anime_origem(self, novo_anime):
        self.__anime_origem = novo_anime

    @status.setter
    def status(self, novo_status):
        self.__status = novo_status

    @nivel_poder.setter
    def nivel_poder(self, novo_poder):
        if novo_poder >= 0:
            self.__nivel_poder = novo_poder
            print(f"Poder de {self.nome} atualizado para {self.__nivel_poder}.")
        else:
            print(f"Erro: Nível de poder ( {novo_poder} ) não pode ser negativo. Valor não alterado.")

    @abstractmethod
    def tecnica_especial(self):
        pass

    def exibir_info(self):
        print(f"\n--- Ficha Técnica ---")
        print(f"Nome: {self.nome}")
        print(f"Origem: {self.anime_origem}")
        print(f"Poder: {self.nivel_poder}")
        print(f"Status: {self.status}")

    def treinar(self, aumento_poder):
        if aumento_poder > 0:
            print(f"{self.nome} está treinando...")
            self.nivel_poder += aumento_poder
        else:
            print("Aumento de poder deve ser positivo.")
class Shinobi(PersonagemAnime):
    def __init__(self, nome, nivel_poder, vila, jutsu_principal='Rasengan'):
        super().__init__(nome, 'Naruto', nivel_poder)
        self.__vila = vila
        self.__jutsu_principal = jutsu_principal

    @property
    def vila(self):
        return self.__vila

    @property
    def jutsu_principal(self):
        return self.__jutsu_principal

    @vila.setter
    def vila(self, nova_vila):
        self.__vila = nova_vila

    @jutsu_principal.setter
    def jutsu_principal(self, novo_jutsu):
        if novo_jutsu and novo_jutsu.strip(): 
            self.__jutsu_principal = novo_jutsu
            print(f"{self.nome} aprendeu um novo jutsu: {self.__jutsu_principal}")
        else:
            print("Erro: O nome do jutsu não pode ser vazio.")

    def tecnica_especial(self):
        print(f"SHINOBI: {self.nome} da {self.vila} usa seu jutsu principal: {self.jutsu_principal}!")

    def realizar_missao(self, rank):
        print(f"{self.nome} está realizando uma missão Rank {rank}.")

class Saiyajin(PersonagemAnime):

    def __init__(self, nome, nivel_poder, universo, transformacao_atual='Base'):
        super().__init__(nome, 'Dragon Ball', nivel_poder)
        self.__universo = universo
        self.__transformacao_atual = transformacao_atual

    @property
    def universo(self):
        return self.__universo
    
    @property
    def transformacao_atual(self):
        return self.__transformacao_atual

    @universo.setter
    def universo(self, novo_universo):
        self.__universo = novo_universo

    @transformacao_atual.setter
    def transformacao_atual(self, nova_forma):
        self.__transformacao_atual = nova_forma

    def tecnica_especial(self):
        print(f"SAIYAJIN: {self.nome} do Universo {self.universo} prepara um... KAMEHAMEHA!")

    def transformar(self, nova_forma):
        print(f"O Ki de {self.nome} está aumentando...!")
        print(f"{self.nome} se transformou em {nova_forma}.")
        self.transformacao_atual = nova_forma
        self.nivel_poder *= 1.5