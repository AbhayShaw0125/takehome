from fastapi import FastAPI,Request,Response
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
from app.routers import average,emwa

app=FastAPI(title="EWMA Assignment API")

app.add_middleware(
    CORSMiddleware,
    #allow_origins=["http://localhost:5173"],
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],  
)

REQUEST_COUNT = Counter(
    "backend_requests_total",
    "Total requests to backend"
)

REQUEST_LATENCY = Histogram(
    "backend_request_latency_seconds",
    "Request latency in seconds"
)

@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    REQUEST_COUNT.inc()
    REQUEST_LATENCY.observe(time.time() - start)
    return response


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)



@app.get("/health")
async def health_check():
    return {"status": "healthy"}
    
app.include_router(average.router)
app.include_router(emwa.router)
