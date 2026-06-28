print("1 - Kütüphaneler çağrılıyor...")
from google import genai 
from pydantic import BaseModel
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
from PIL import Image, UnidentifiedImageError
import uuid
import os
import json


print("1.5 - Gemini API anahtarı yükleniyor... ")
client = genai.Client(api_key="YOUR_API_KEY")  # Replace with your actual API key

print("1.6 - Flutter mesajlaşma için format belirleniyor...")
class ChatMessage(BaseModel):
    text: str

# -------------------------------------------------
#  BİRD INFO JSON YÜKLEME
# -------------------------------------------------
try:
    with open("BirdInfo.json", "r", encoding="utf-8") as f:
        BIRD_INFO = json.load(f)
    BIRD_INFO_NORMALIZED = {
        key.strip().lower().replace(" ", "_"): value
        for key, value in BIRD_INFO.items()
    }
except FileNotFoundError:
    print("UYARI: BirdInfo.json dosyası bulunamadı!")
    BIRD_INFO_NORMALIZED = {}

# -------------------------------------------------
#  FASTAPI UYGULAMASI VE CORS AYARLARI
# -------------------------------------------------
print("2 - FastAPI başlatılıyor...")
app = FastAPI(title="BirdBase API", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
RESULT_DIR = "outputs/result"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(RESULT_DIR, exist_ok=True)
app.mount("/outputs", StaticFiles(directory="outputs"), name="outputs")

# -------------------------------------------------
#  YOLO MODELİNİ YÜKLEME
# -------------------------------------------------
MODEL_PATH = "best_vastai.pt" 
try:
    print("3 - YOLO Modeli yükleniyor...")
    model = YOLO(MODEL_PATH)
except Exception as e:
    print(f"HATA: Model yüklenemedi. Detay: {e}")

@app.get("/")
def home():
    return {"status": "BirdBase API is running successfully!"}

print("4 - Model başarıyla yüklendi! Her şey hazır.")

# -------------------------------------------------
#  TAHMİN (PREDICT) ENDPOINT'İ
# -------------------------------------------------
@app.post("/predict")
async def predict(image: UploadFile = File(...)):
    try:
        pil_image = Image.open(image.file)
    except UnidentifiedImageError:
        raise HTTPException(status_code=400, detail="Uploaded file is not a valid image.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading image: {str(e)}")

    pil_image = pil_image.convert("RGB")
    random_name = f"{uuid.uuid4()}.jpg"
    upload_path = os.path.join(UPLOAD_DIR, random_name)
    output_path = os.path.join(RESULT_DIR, random_name)
    
    pil_image.save(upload_path, "JPEG")

    results = model.predict(source=upload_path, conf=0.25, verbose=False)

    detections = []
    bird_info = None
    output_image_url = None
    formatted_message = "No birds were detected in the image."
    
    if len(results) > 0 and len(results[0].boxes) > 0: 
        result = results[0]
        res_plotted = result.plot() 
        res_rgb = res_plotted[..., ::-1] 
        Image.fromarray(res_rgb).save(output_path, "JPEG")
        
        output_image_url = f"/outputs/result/{random_name}"

        # İsim Temizleme ve Tekilleştirme
        unique_birds = {}
        for box in result.boxes:
            cls_id = int(box.cls[0])
            raw_class_name = model.names[cls_id]
            confidence = float(box.conf[0]) * 100
            clean_class_name = raw_class_name.split('(')[0].strip()

            if clean_class_name not in unique_birds or confidence > unique_birds[clean_class_name]:
                unique_birds[clean_class_name] = round(confidence, 2)

        # İlk 3'ü alma ve listeye çevirme
        top_birds = sorted(
            [{"class": name, "confidence": conf} for name, conf in unique_birds.items()],
            key=lambda x: x["confidence"],
            reverse=True
        )[:3]

        if top_birds:
            bird_names = [bird["class"] for bird in top_birds]
            
            # --- DİNAMİK İNGİLİZCE MESAJ MANTIĞI ---
            if len(bird_names) > 1:
                # 1'den fazla FARKLI kuş türü varsa
                formatted_message = "I am sure the bird you are looking for is one of these species:\n\n" + "\n".join([f"• {name}" for name in bird_names])
            else:
                # Sadece 1 net kuş türü varsa (Aynı kuşun adult/immature halleri de tekilleşip buraya düşer)
                formatted_message = f"This is the bird species you are looking for:\n\n• {bird_names[0]}"
            
            # API'den confidence'ı tamamen uçuruyoruz, sadece isim gidiyor
            detections = [{"class": name} for name in bird_names]

            best_detection = top_birds[0]
            detected_class = best_detection["class"].strip().lower().replace(" ", "_")

            if detected_class in BIRD_INFO_NORMALIZED:
                bird_info = BIRD_INFO_NORMALIZED[detected_class]
            
    else:
        pil_image.save(output_path, "JPEG")
        output_image_url = f"/outputs/result/{random_name}"

    # 6) Temiz JSON Dönüşü
    return {
        "success": True if detections else False,
        "message": formatted_message,
        "output_image": output_image_url,
        "detections": detections,
        "bird_info": bird_info
    }

@app.post("/chat")
async def chat_with_gemini(message: ChatMessage):
    try:
        response = client.models.generate_content(
            model='gemini-flash-latest', 
            contents=message.text
        )
        return {"success": True, "reply": response.text}
    except Exception as e:
        return {"success": False, "reply": f"Connection error: {str(e)}"}



#uvicorn api:app --reload
#uvicorn api:app --host 0.0.0.0 --port 8000 --reload
#http://127.0.0.1:8000/docs
#python3.11 -m venv venv
#source venv/bin/activate
#pip install --upgrade pip
#pip install -r requirements.txt
#pip freeze > requirements.txt