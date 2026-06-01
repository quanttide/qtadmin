from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from fastapi_quanttide_finance.routers import source_records

app = FastAPI(title="QuantTide Finance Toolkit")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


app.include_router(source_records.router)
