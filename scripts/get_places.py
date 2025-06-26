import requests
import os
import json
import logging
from typing import List, Tuple, Dict, Any, Optional

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

API_KEY: Optional[str] = os.getenv("MAPS_API_KEY")

if not API_KEY:
    logging.error("API Key Bulunamadı!")
    raise ValueError("API Key Bulunamadı!")

BASE_URL: str = "https://places.googleapis.com/v1/places:searchNearby"

HEADERS: Dict[str, str] = {
    "Content-Type": "application/json",
    "X-Goog-FieldMask": (
        "places.id,places.displayName,places.location,places.rating,"
        "places.userRatingCount,places.formattedAddress,"
        "places.primaryTypeDisplayName,places.reviews,"
        "places.iconBackgroundColor,places.iconMaskBaseUri"
    ),
    "X-Goog-Api-Key": API_KEY,
}


def get_nearby_places(
    locations: List[Tuple[float, float]],
    radius_meters: int = 1000,
    language_code: str = "tr",
    max_results: int = 20,
) -> List[Dict[str, Any]]:
    all_places: List[Dict[str, Any]] = []
    with requests.Session() as session:
        session.headers.update(HEADERS)
        for lat, lng in locations:
            logging.info(f"Konum ({lat}, {lng}) için yerler aranıyor...")
            payload: Dict[str, Any] = {
                "maxResultCount": max_results,
                "locationRestriction": {
                    "circle": {
                        "center": {"latitude": lat, "longitude": lng},
                        "radius": radius_meters,
                    }
                },
                "languageCode": language_code,
            }
            try:
                response: requests.Response = session.post(
                    BASE_URL, json=payload, timeout=5
                )
                response.raise_for_status()
                response_data: Dict[str, Any] = response.json()
                places_found: List[Dict[str, Any]] = response_data.get("places", [])
                logging.info(
                    f"Konum ({lat}, {lng}) için {len(places_found)} yer bulundu."
                )
                all_places.extend(places_found)
            except requests.exceptions.HTTPError as http_err:
                logging.error(
                    f"HTTP hatası oluştu: {http_err} - Yanıt: {response.text}"  # type: ignore
                )
            except requests.exceptions.ConnectionError as conn_err:
                logging.error(f"Bağlantı hatası oluştu: {conn_err}")
            except requests.exceptions.Timeout as timeout_err:
                logging.error(f"İstek zaman aşımına uğradı: {timeout_err}")
            except requests.exceptions.RequestException as req_err:
                logging.error(f"Bir hata oluştu: {req_err}")
            except json.JSONDecodeError as json_err:
                logging.error(
                    f"JSON yanıtı çözümlenemedi: {json_err} - Yanıt içeriği: {response.text}"  # type: ignore
                )
    return all_places


def save_places_to_json(
    places_data: List[Dict[str, Any]], filename: str = "places.json"
):
    output_data: Dict[str, List[Dict[str, Any]]] = {"places": places_data}
    try:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        logging.info(f"İşletme verileri '{filename}' dosyasına başarıyla kaydedildi.")
    except IOError as e:
        logging.error(f"Dosya yazma hatası oluştu '{filename}': {e}")
    except Exception as e:
        logging.error(f"Verileri JSON'a kaydederken beklenmeyen bir hata oluştu: {e}")


if __name__ == "__main__":
    logging.info("Program başlatılıyor...")

    locations: List[Tuple[float, float]] = [
        (41.065850, 28.905881), # Evim
        (41.078357, 28.990996), # Kağıthane, Gültepe
        (41.110109, 29.024971), # Sarıyer Maslak NarPOS
        (41.091150, 29.061505), # FSM Köprüsü
    ]
    found_places: List[Dict[str, Any]] = get_nearby_places(locations)

    if found_places:
        save_places_to_json(found_places)
    else:
        logging.warning(
            "Hiç İşletme bulunamadı veya bir hata oluştuğu için kaydedilecek veri yok."
        )
    logging.info("Program tamamlandı.")
