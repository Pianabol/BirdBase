from ultralytics import YOLO

print("1 - Backend'deki asıl modelin beynine giriliyor...")
# Backend'de çalışan modelinin adını buraya yazıyoruz
model = YOLO("best_vastai.pt") 

print("2 - İsim sözlüğü çekiliyor...")
# Modelin içindeki listeyi alıp labels.txt olarak kaydediyoruz
with open("labels.txt", "w", encoding="utf-8") as f:
    for i in range(len(model.names)):
        f.write(f"{model.names[i]}\n")

print(f"3 - İşlem tamam! Tam {len(model.names)} adet kuş labels.txt dosyasına yazıldı.")
