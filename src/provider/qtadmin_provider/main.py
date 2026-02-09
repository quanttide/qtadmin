from fastapi import FastAPI

app = FastAPI(
    title="量潮管理后台服务端",
    description="量潮管理后台服务端API",
    version="0.0.1"
)

@app.get("/")
async def index():
    return {"message": "Hello, world!"}
