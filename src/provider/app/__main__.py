import uvicorn
from fastapi import FastAPI

app = FastAPI(title="qtadmin API", version="0.1.0")

@app.get("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
