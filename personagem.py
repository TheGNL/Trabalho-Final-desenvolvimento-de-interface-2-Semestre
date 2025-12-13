class Personagem:
    def __init__(self, nome, nivel):
        self.nome = nome
        self.nivel = nivel

    def __str__(self):
        return f"Personagem: {self.nome}, Nível: {self.nivel}"
