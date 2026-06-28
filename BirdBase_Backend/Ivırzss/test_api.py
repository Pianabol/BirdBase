from google import genai

# Kendi API anahtarın
client = genai.Client(api_key="YOUR_API_KEY") 

print("Senin API anahtarınla çalışan modeller taranıyor...\n")

try:
    for m in client.models.list():
        # İsminde 'gemini' geçen modelleri filtreleyelim
        if "gemini" in m.name.lower():
            print(f"✅ Kullanılabilir Model: {m.name}")
except Exception as e:
    print("Hata oluştu:", e)