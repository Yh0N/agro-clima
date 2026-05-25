"""Tests para los handlers del bot de Telegram (comandos y datos de cultivos)."""
import pytest
from bot.handlers import CULTIVOS, MUNICIPIO, VEREDA, ALTITUD


class TestCultivosData:
    """Valida los datos estáticos de fichas de cultivos."""

    def test_cultivos_tiene_papa(self):
        assert "papa" in CULTIVOS

    def test_cultivos_tiene_mora(self):
        assert "mora" in CULTIVOS

    def test_cultivos_tiene_cafe(self):
        assert "cafe" in CULTIVOS

    def test_papa_contiene_info_altitud(self):
        assert "Altitud" in CULTIVOS["papa"] or "altitud" in CULTIVOS["papa"]

    def test_mora_contiene_info_cosecha(self):
        assert "Cosecha" in CULTIVOS["mora"] or "cosecha" in CULTIVOS["mora"]

    def test_cafe_contiene_info_broca(self):
        assert "broca" in CULTIVOS["cafe"] or "Broca" in CULTIVOS["cafe"]

    def test_cada_cultivo_tiene_texto(self):
        """Todas las fichas deben tener contenido."""
        for nombre, texto in CULTIVOS.items():
            assert len(texto) > 20, f"La ficha de {nombre} está vacía o muy corta"

    def test_fichas_tienen_emoji(self):
        """Las fichas deben incluir emojis para ser visualmente atractivas."""
        for nombre, texto in CULTIVOS.items():
            assert any(c for c in texto if ord(c) > 127), f"La ficha de {nombre} no tiene emojis"


class TestConversationStates:
    """Valida que los estados de conversación estén bien definidos."""

    def test_estados_son_enteros(self):
        assert isinstance(MUNICIPIO, int)
        assert isinstance(VEREDA, int)
        assert isinstance(ALTITUD, int)

    def test_estados_son_secuenciales(self):
        assert MUNICIPIO == 0
        assert VEREDA == 1
        assert ALTITUD == 2

    def test_estados_son_distintos(self):
        assert MUNICIPIO != VEREDA
        assert VEREDA != ALTITUD
        assert MUNICIPIO != ALTITUD
