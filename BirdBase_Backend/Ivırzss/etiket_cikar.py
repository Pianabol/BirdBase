from ultralytics import YOLO

# 1. Eğitilmiş modeli yükle
model = YOLO("best_vastai.pt")

# 2. Modelin beynindeki o gizli sözlüğü (Index -> İsim) al
isimler = model.names

# 3. İsimleri tam sırasıyla labels.txt dosyasına yazdır
with open("labels.txt", "w", encoding="utf-8") as dosya:
    # 0'dan başlayarak tüm türleri alt alta yaz
    for i in range(len(isimler)):
        dosya.write(f"{isimler[i]}\n")

print("🚀 labels.txt dosyası milimetrik sırayla oluşturuldu!")
