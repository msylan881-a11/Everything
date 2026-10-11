import os
import uuid
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

APP_NAME = os.getenv("APP_NAME", "NAQSH AI API")
MAX_UPLOAD_MB = int(os.getenv("MAX_UPLOAD_MB", "15"))
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}

app = FastAPI(title=APP_NAME, version="0.2.0")

if os.getenv("ENVIRONMENT", "development") == "development":
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["GET", "POST"],
        allow_headers=["*"],
    )

class HealthResponse(BaseModel):
    status: str
    app: str
    ai_provider: str

@app.get("/health", response_model=HealthResponse)
def health():
    return HealthResponse(
        status="ok",
        app=APP_NAME,
        ai_provider=os.getenv("AI_PROVIDER", "not_configured"),
    )

@app.get("/")
def root():
    return {"name": APP_NAME, "docs": "/docs", "health": "/health"}

@app.post("/v1/edits")
async def create_edit(
    image: UploadFile = File(...),
    prompt: str = Form(..., min_length=3, max_length=2000),
):
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(415, "نوع الصورة غير مدعوم. استخدم JPG أو PNG أو WebP.")
    content = await image.read()
    if not content:
        raise HTTPException(400, "الملف فارغ.")
    if len(content) > MAX_UPLOAD_MB * 1024 * 1024:
        raise HTTPException(413, f"حجم الصورة أكبر من الحد ({MAX_UPLOAD_MB} MB).")
    if not os.getenv("AI_API_KEY") or os.getenv("AI_PROVIDER", "not_configured") == "not_configured":
        raise HTTPException(
            503,
            "لم يتم ربط مزوّد ذكاء اصطناعي لمعالجة الصور بعد. أضف المزوّد ومفتاحه إلى الخادم.",
        )
    # Intentionally fail closed until a provider adapter is implemented and tested.
    raise HTTPException(
        501,
        f"إعداد المزوّد موجود لكن موصل التحرير لم ينفذ بعد. رقم الطلب: {uuid.uuid4()}",
    )
