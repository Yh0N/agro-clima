"""Tests para WeatherService del bot de Telegram."""
import pytest
from bot.services.weather_service import WeatherService


class TestWeatherServiceMunicipios:
    """Tests para la carga de municipios locales (sin red)."""

    def setup_method(self):
        self.service = WeatherService()

    def test_get_municipios_retorna_dict(self):
        """El JSON de municipios carga correctamente como diccionario."""
        muns = self.service.get_municipios()
        assert isinstance(muns, dict)

    def test_get_municipios_tiene_pasto(self):
        """El JSON contiene a Pasto como municipio base."""
        muns = self.service.get_municipios()
        assert "Pasto" in muns

    def test_municipio_tiene_lat_lon(self):
        """Cada municipio tiene latitud y longitud."""
        muns = self.service.get_municipios()
        for nombre, data in muns.items():
            assert "lat" in data, f"{nombre} no tiene 'lat'"
            assert "lon" in data, f"{nombre} no tiene 'lon'"
            assert isinstance(data["lat"], (int, float))
            assert isinstance(data["lon"], (int, float))

    def test_municipio_tiene_altitud(self):
        """Cada municipio tiene su altitud en metros."""
        muns = self.service.get_municipios()
        for nombre, data in muns.items():
            assert "altitud" in data, f"{nombre} no tiene 'altitud'"
            assert data["altitud"] > 0

    def test_hay_al_menos_5_municipios(self):
        """El archivo tiene al menos 5 municipios de Nariño."""
        muns = self.service.get_municipios()
        assert len(muns) >= 5

    def test_coordenadas_en_rango_colombia(self):
        """Las coordenadas están dentro del rango de Colombia."""
        muns = self.service.get_municipios()
        for nombre, data in muns.items():
            assert -5 <= data["lat"] <= 13, f"{nombre} lat fuera de rango: {data['lat']}"
            assert -82 <= data["lon"] <= -66, f"{nombre} lon fuera de rango: {data['lon']}"


class TestWeatherServiceForecast:
    """Tests para la llamada a la API de clima (requiere internet)."""

    def setup_method(self):
        self.service = WeatherService()

    @pytest.mark.asyncio
    async def test_forecast_pasto_retorna_datos(self):
        """Consulta real a Open-Meteo para Pasto retorna datos válidos."""
        result = await self.service.get_forecast(lat=1.214, lon=-77.279)
        assert result is not None
        assert "daily" in result
        assert "temperature_2m_min" in result["daily"]
        assert "temperature_2m_max" in result["daily"]
        assert len(result["daily"]["temperature_2m_min"]) == 7

    @pytest.mark.asyncio
    async def test_forecast_tiene_todas_las_variables(self):
        """El pronóstico incluye todas las variables que necesita el bot."""
        result = await self.service.get_forecast(lat=1.214, lon=-77.279)
        assert result is not None
        daily = result["daily"]
        assert "temperature_2m_min" in daily
        assert "temperature_2m_max" in daily
        assert "precipitation_probability_mean" in daily
        assert "windspeed_10m_max" in daily
