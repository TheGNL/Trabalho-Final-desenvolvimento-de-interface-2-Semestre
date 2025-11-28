from personagem import Personagem

class Heroi(Personagem):
    def __init__(self, nome, nivel, poder):
        super().__init__(nome, nivel)
        self.poder = poder

    def __str__(self):
        return f"Herói: {self.nome}, Nível: {self.nivel}, Poder: {self.poder}"
