from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from database import SessionLocal
from models import Material

router = APIRouter(
    prefix="/api/inventory",
    tags=["inventory"]
)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class MaterialResponse(BaseModel):
    id: int
    name: str
    cas_number: Optional[str]
    price_per_kg: Optional[float]
    inventory_level: Optional[float]
    ghs_tags: Optional[List[str]]

    class Config:
        orm_mode = True

@router.get("/search", response_model=List[MaterialResponse])
def search_inventory(q: str = "", db: Session = Depends(get_db)):
    if not q:
        return db.query(Material).limit(50).all()
    
    return db.query(Material).filter(Material.name.ilike(f"%{q}%")).all()

@router.get("/materials", response_model=List[MaterialResponse])
def get_all_materials(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Material).offset(skip).limit(limit).all()
