"""Tests para FrostPredictor y SprayPredictor del bot de Telegram."""
import pytest
from bot.services.frost_predictor import FrostPredictor, SprayPredictor


class TestFrostPredictor:
    """Tests para la lógica de predicción de heladas."""

    def setup_method(self):
        self.predictor = FrostPredictor()

    # ── Riesgo ALTO ──────────────────────────────────────────────────────────

    def test_riesgo_alto_temp_bajo_cero_altitud_alta(self):
        """Temperatura bajo cero + altitud alta = riesgo ALTO."""
        result = self.predictor.predict(
            altitud=3200, temp_min=-2.0, humedad=30, mes=7, nubosidad=20
        )
        assert "ALTO" in result["level"]
        assert any("bajo cero" in f.lower() or "❄️" in f for f in result["factors"])
        assert "Protege" in result["recommendation"] or "⚠️" in result["recommendation"]

    def test_riesgo_alto_temp_muy_baja_y_cielo_despejado(self):
        """Cielo despejado + temperatura peligrosa = factores de helada radiativa."""
        result = self.predictor.predict(
            altitud=2800, temp_min=1.0, humedad=25, mes=1, nubosidad=15
        )
        assert "ALTO" in result["level"] or "MEDIO" in result["level"]
        assert any("radiativa" in f.lower() or "despejado" in f.lower() for f in result["factors"])

    # ── Riesgo MEDIO ─────────────────────────────────────────────────────────

    def test_riesgo_medio_temp_moderada(self):
        """Temperatura baja pero no extrema = riesgo medio."""
        result = self.predictor.predict(
            altitud=2600, temp_min=3.0, humedad=60, mes=3, nubosidad=50
        )
        assert "MEDIO" in result["level"]

    # ── Riesgo BAJO ──────────────────────────────────────────────────────────

    def test_riesgo_bajo_condiciones_normales(self):
        """Condiciones normales sin riesgo."""
        result = self.predictor.predict(
            altitud=1800, temp_min=12.0, humedad=60, mes=4, nubosidad=60
        )
        assert "BAJO" in result["level"]
        assert "Condiciones normales" in result["factors"]
        assert "Sin riesgo" in result["recommendation"] or "✅" in result["recommendation"]

    # ── Estructura del resultado ─────────────────────────────────────────────

    def test_resultado_tiene_claves_completas(self):
        """El dict de resultado tiene las 4 claves esperadas."""
        result = self.predictor.predict(
            altitud=2500, temp_min=5.0, humedad=50, mes=6
        )
        assert "level" in result
        assert "confidence" in result
        assert "factors" in result
        assert "recommendation" in result
        assert isinstance(result["factors"], list)
        assert "%" in result["confidence"]

    def test_confianza_en_rango_valido(self):
        """La confianza siempre debe estar entre 55% y 95%."""
        for temp in [-5, 0, 3, 8, 15]:
            result = self.predictor.predict(
                altitud=2500, temp_min=temp, humedad=50, mes=6
            )
            confidence_val = int(result["confidence"].replace("%", ""))
            assert 55 <= confidence_val <= 95

    # ── Factores de altitud ──────────────────────────────────────────────────

    def test_altitud_mayor_3000_suma_factor(self):
        result = self.predictor.predict(
            altitud=3100, temp_min=8.0, humedad=50, mes=3, nubosidad=50
        )
        assert any("altitud" in f.lower() for f in result["factors"])

    def test_altitud_baja_sin_factor(self):
        result = self.predictor.predict(
            altitud=1500, temp_min=15.0, humedad=60, mes=4, nubosidad=60
        )
        assert "Condiciones normales" in result["factors"]

    # ── Meses secos ──────────────────────────────────────────────────────────

    def test_mes_seco_incrementa_riesgo(self):
        """Los meses 1,2,6,7,8,12 (secos en Nariño) incrementan el riesgo."""
        result_seco = self.predictor.predict(
            altitud=2600, temp_min=4.0, humedad=50, mes=7, nubosidad=50
        )
        result_lluvioso = self.predictor.predict(
            altitud=2600, temp_min=4.0, humedad=50, mes=4, nubosidad=50
        )
        # El riesgo en mes seco debe ser igual o mayor
        nivel_seco = 2 if "ALTO" in result_seco["level"] else 1 if "MEDIO" in result_seco["level"] else 0
        nivel_lluv = 2 if "ALTO" in result_lluvioso["level"] else 1 if "MEDIO" in result_lluvioso["level"] else 0
        assert nivel_seco >= nivel_lluv


class TestSprayPredictor:
    """Tests para la lógica de recomendación de fumigación."""

    def setup_method(self):
        self.predictor = SprayPredictor()

    def test_condiciones_ideales_si_se_puede(self):
        """Viento bajo + poca lluvia = se puede fumigar."""
        result = self.predictor.is_good_to_spray(wind_speed=10, rain_prob=20)
        assert result["is_good"] is True
        assert "SÍ" in result["message"]

    def test_viento_fuerte_no_se_puede(self):
        """Viento > 20 km/h = no se puede fumigar."""
        result = self.predictor.is_good_to_spray(wind_speed=25, rain_prob=10)
        assert result["is_good"] is False
        assert "viento" in result["message"].lower() or "Viento" in result["message"]

    def test_lluvia_alta_no_se_puede(self):
        """Probabilidad de lluvia > 40% = no se puede fumigar."""
        result = self.predictor.is_good_to_spray(wind_speed=10, rain_prob=60)
        assert result["is_good"] is False
        assert "lluvia" in result["message"].lower() or "agua" in result["message"].lower()

    def test_ambos_malos_no_se_puede(self):
        """Viento fuerte + lluvia = no se puede."""
        result = self.predictor.is_good_to_spray(wind_speed=30, rain_prob=80)
        assert result["is_good"] is False

    def test_resultado_incluye_mejor_hora(self):
        """Siempre se incluye la mejor hora para fumigar."""
        result = self.predictor.is_good_to_spray(wind_speed=10, rain_prob=20)
        assert "best_time" in result
        assert len(result["best_time"]) > 0

    def test_limite_exacto_viento_20(self):
        """Viento exacto de 20 km/h = aún se puede (< 20 es OK)."""
        result = self.predictor.is_good_to_spray(wind_speed=20, rain_prob=10)
        assert result["is_good"] is False  # 20 no es < 20

    def test_limite_exacto_lluvia_40(self):
        """Lluvia exacta de 40% = ya no se puede (< 40 es OK)."""
        result = self.predictor.is_good_to_spray(wind_speed=10, rain_prob=40)
        assert result["is_good"] is False  # 40 no es < 40
