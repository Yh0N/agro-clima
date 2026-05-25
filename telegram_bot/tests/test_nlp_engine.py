"""Tests para NLPEngine del bot de Telegram (modo keyword fallback)."""
import pytest
from unittest.mock import patch
from bot.services.nlp_engine import NLPEngine


class TestNLPEngineKeywordFallback:
    """
    Testea el modo de fallback por palabras clave del NLPEngine.
    Estos tests corren SIN necesidad de una API key de Gemini.
    """

    def setup_method(self):
        # Forzar que no haya API key para usar el fallback por keywords
        with patch.dict("os.environ", {"GEMINI_API_KEY": ""}, clear=False):
            self.engine = NLPEngine()
        # Asegurar que is_enabled esté deshabilitado
        self.engine.is_enabled = False

    # ── Intención: HELADA ────────────────────────────────────────────────────

    def test_detecta_helada_directa(self):
        assert self.engine.analyze_intent("¿Va a caer helada esta noche?") == "HELADA"

    def test_detecta_helada_con_frio(self):
        assert self.engine.analyze_intent("¿Va a hacer mucho frío mañana?") == "HELADA"

    def test_detecta_helada_con_hielo(self):
        assert self.engine.analyze_intent("Está cayendo hielo en la finca") == "HELADA"

    # ── Intención: FUMIGAR ───────────────────────────────────────────────────

    def test_detecta_fumigar_directa(self):
        assert self.engine.analyze_intent("¿Puedo fumigar hoy?") == "FUMIGAR"

    def test_detecta_fumigar_con_veneno(self):
        assert self.engine.analyze_intent("¿Es buen día pa echar veneno?") == "FUMIGAR"

    def test_detecta_fumigar_con_agroquimico(self):
        assert self.engine.analyze_intent("¿Puedo aplicar agroquímico?") == "FUMIGAR"

    # ── Intención: CLIMA_HOY ─────────────────────────────────────────────────

    def test_detecta_clima_hoy_con_lluvia(self):
        assert self.engine.analyze_intent("¿Va a llover hoy?") == "CLIMA_HOY"

    def test_detecta_clima_hoy_con_ahora(self):
        assert self.engine.analyze_intent("¿Cómo está el clima ahora?") == "CLIMA_HOY"

    def test_detecta_clima_hoy_con_agua(self):
        assert self.engine.analyze_intent("¿Va a caer agua?") == "CLIMA_HOY"

    # ── Intención: CLIMA_SEMANA ──────────────────────────────────────────────

    def test_detecta_clima_semana(self):
        assert self.engine.analyze_intent("¿Cómo estará el clima esta semana?") == "CLIMA_SEMANA"

    def test_detecta_pronostico(self):
        assert self.engine.analyze_intent("Deme el pronóstico") == "CLIMA_SEMANA"

    def test_detecta_tiempo(self):
        assert self.engine.analyze_intent("¿Cómo estará el tiempo?") == "CLIMA_SEMANA"

    # ── Intención: AYUDA ─────────────────────────────────────────────────────

    def test_detecta_ayuda(self):
        assert self.engine.analyze_intent("Necesito ayuda") == "AYUDA"

    def test_detecta_comandos(self):
        assert self.engine.analyze_intent("¿Qué comandos tienes?") == "AYUDA"

    # ── Intención: DESCONOCIDO ───────────────────────────────────────────────

    def test_detecta_desconocido(self):
        assert self.engine.analyze_intent("Mi perro se llama Firulais") == "DESCONOCIDO"

    def test_detecta_desconocido_numeros(self):
        assert self.engine.analyze_intent("12345") == "DESCONOCIDO"

    def test_detecta_desconocido_vacio(self):
        assert self.engine.analyze_intent("") == "DESCONOCIDO"

    # ── Insensibilidad a mayúsculas ──────────────────────────────────────────

    def test_mayusculas_helada(self):
        assert self.engine.analyze_intent("HELADA") == "HELADA"

    def test_mixto_fumigar(self):
        assert self.engine.analyze_intent("Fumigar los cultivos") == "FUMIGAR"
