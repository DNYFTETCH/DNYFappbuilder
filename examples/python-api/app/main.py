from fastapi import FastAPI

app = FastAPI(title="DNYFappbuilder Python Example", version="1.0.0")

@app.get("/")
async def root():
    return {"status": "ok", "app": "DNYFappbuilder Python Example", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
