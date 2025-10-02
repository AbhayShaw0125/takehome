from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import average,emwa

app=FastAPI(title="EWMA Assignment API")

app.add_middleware(
    CORSMiddleware,
    #allow_origins=["http://localhost:5173"],
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],  
)

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
    
app.include_router(average.router)
app.include_router(emwa.router)
