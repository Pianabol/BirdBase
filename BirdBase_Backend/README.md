# BirdBase Backend (API & Inference Engine)

The core processing unit for the online pipeline, built with **Python** and **FastAPI**.

## Features
* **High-Precision Inference:** Hosts the robust `YOLOv8s` model, extensively trained over 180 epochs for maximum classification accuracy.
* **Service-Oriented Architecture:** Strictly decoupled services for image preprocessing, prediction, and API routing.
* **LLM Integration:** Features a dedicated `ChatbotService` that connects to the Gemini API, automatically generating rich insights based on the detected species label.