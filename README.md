# BirdBase: AI-Powered Avian Expert & Detection System

<div align="center">
  <img src="https://img.shields.io/badge/TÜBİTAK-2209--A-19328?style=for-the-badge&logo=tubitak&color=blue" alt="TÜBİTAK 2209-A">
  <img src="https://img.shields.io/badge/Architecture-Monorepo-success?style=for-the-badge&color=brightgreen">
  <img src="https://img.shields.io/badge/AI_Engine-YOLOv8%20%7C%20Gemini-orange?style=for-the-badge">
  <img src="https://img.shields.io/badge/Platform-Flutter%20%7C%20FastAPI%20%7C%20Web-lightgrey?style=for-the-badge">
</div>

<br>

## Project Overview & Live Access
BirdBase is an advanced, end-to-end avian species detection and consultation platform. Supported by the **TÜBİTAK 2209-A University Students Research Projects Support Program**, this system bridges the gap between field exploration and deep learning architecture.

**Access Our Live Web Platform:** [BirdBase on Hugging Face](https://huggingface.co/spaces/Pianabol/BirdBase)

---

## Interface Previews

<div align="center">
  <img src="Assets/App1.png" alt="BirdBase Mobile App 1" width="24%">
  <img src="Assets/App2.png" alt="BirdBase Mobile App 2" width="24%">
  <img src="Assets/App3.png" alt="BirdBase Mobile App 3" width="24%">
  <img src="Assets/App4.png" alt="BirdBase Mobile App 4" width="24%">
</div>
<br>
<div align="center">
  <img src="Assets/Web1.png" alt="BirdBase Web Interface 1" width="48.5%">
  <img src="Assets/Web2.png" alt="BirdBase Web Interface 2" width="48.5%">
</div>

---

## Vision & Mission
**Mission:** To bridge the gap between nature exploration and deep learning technology by providing an accessible, highly accurate, and robust bird species recognition platform designed for both urban environments and remote field locations.

**Vision:** To establish a scalable, end-to-end AI architecture that sets a new standard for biological detection systems, leveraging edge computing for zero-latency offline inferences and cloud computing for advanced LLM consultations.

---

## Key Features

### Offline Mode: Zero-Latency Edge Computing
* **Local Inference:** Utilizes a highly optimized, lightweight YOLOv8 Nano (~10MB) TFLite model running directly on the device's processor.
* **No Internet Dependency:** Engineered for field researchers and nature enthusiasts. The system identifies species and extracts detailed biological data from a built-in 2,600+ line JSON database instantly, without requiring network access.

### Online Mode: High-Precision Cloud API
* **Advanced Cloud Inference:** Routes complex image requests to our robust FastAPI backend, triggering the YOLOv8 Small model (~70MB). This model was rigorously trained over 180 epochs to ensure maximum classification accuracy across more than 400 complex avian species.
* **Avian Expert Integration:** Features an interactive extension powered by the Google Gemini LLM API. Users can consult the AI system to obtain detailed, AI-generated insights regarding the detected bird species with a single interaction.

---

## System Architecture (Monorepo)
BirdBase is engineered with a strict adherence to the Separation of Concerns principle, adopting a Service-Oriented Architecture within a comprehensive Monorepo structure.

* **BirdBaseApp:** The mobile frontend built with Flutter and Dart. It handles local TFLite execution, offline JSON mapping, and clean UI/UX rendering.
* **BirdBase_Backend:** The cloud engine built with FastAPI (Python). It manages asynchronous image processing requests, YOLO model inference, and external LLM API communications via dedicated services (`PredictionService`, `ChatbotService`).
* **Web:** A responsive static web interface providing cross-platform access to our online AI pipeline.

---

## Technology Stack
* **Machine Learning & AI:** Ultralytics YOLOv8 (Nano & Small), TensorFlow Lite, Google Gemini LLM API
* **Backend:** Python, FastAPI, Uvicorn
* **Frontend (Mobile):** Flutter, Dart
* **Frontend (Web):** HTML, CSS, JavaScript

---

## Contributors & Acknowledgments
This ecosystem was engineered and developed by:
* **Furkan Tuç**
* **Nisa Doğa Yücel**

> **Official Acknowledgment:**
> This project is officially supported and funded by the **TÜBİTAK 2209-A University Students Research Projects Support Program**. We extend our gratitude to TÜBİTAK for their contribution to scientific research and technological development.